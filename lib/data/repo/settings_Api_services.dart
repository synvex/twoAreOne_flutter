import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/Error/api_error.dart';
import '../../core/constants/app_constants.dart';
import '../end_points.dart';
import 'storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Port of `src/global/Helpers/ApiManager.js`.
///
/// RN used axios with `axios.defaults.headers.common[...]` as a global
/// mutable auth header. We reproduce that exact behavior with static fields
/// (`setUpRequestTokenAxios` / `removeRequestTokenAxios`), so every call site
/// that used to rely on "axios already has the token" keeps working unchanged.
class ApiService {
  ApiService._();

  static const Duration _timeout = Duration(seconds: 30);

  /// mirrors `axios.defaults.headers.common`
  static String? _authToken;

  /// Called by `AuthViewModel` when a 401 / expired-token response comes back,
  /// exactly like `store.dispatch(LogOut())` did in ApiManager.js. Wired once
  /// in `main.dart` (`ApiService.onSessionExpired = authViewModel.logOut`).
  static void Function()? onSessionExpired;

  /// `ApiManager.setUpRequestTokenAxios(token)`
  static void setUpRequestTokenAxios(String token) {
    _authToken = token;
  }

  /// `ApiManager.removeRequestTokenAxios()`
  static void removeRequestTokenAxios() {
    _authToken = null;
  }

  static Map<String, String> _mergedHeaders(Map<String, String>? apiHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?apiHeaders,
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      headers['x-api-key'] = _authToken!;
    }
    return headers;
  }

  /// `ApiManager.fetch(api, parameters, onResponse, onError)`.
  ///
  /// [api] mirrors the `{method, url, headers}` objects exported from
  /// `global/Apis/*.js`. GET requests send [parameters] as query params,
  /// everything else sends them as a JSON body - same branching as
  /// `api.method == "get" ? undefined : parameters` in the original.
  static Future<void> fetch(
      ApiEndpoint api,
      Map<String, dynamic>? parameters,
      void Function(Map<String, dynamic> response) onResponse,
      void Function(ApiError error) onError,
      ) async {
    try {
      final uri = _buildUri(api.url, api.isGet ? parameters : null);
      final headers = _mergedHeaders(api.headers);

      final http.Response res;
      if (api.isGet) {
        res = await http.get(uri, headers: headers).timeout(_timeout);
      } else {
        res = await http
            .post(uri, headers: headers, body: parameters == null ? null : jsonEncode(parameters))
            .timeout(_timeout);
      }

      final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        onResponse(decoded);
        return;
      }

      _handleApiError(
        statusCode: res.statusCode,
        message: decoded['message']?.toString(),
        api: api,
        parameters: parameters,
        onResponse: onResponse,
        onError: onError,
      );
    } on TimeoutException {
      onError( ApiError(
        title: 'No internet',
        message: 'Please check your internet connection',
        isNetworkError: true,
        alertActionButton: 'Retry',
      ));
    } catch (e) {
      // Matches the RN `error.message === "Network Error"` branch for offline/DNS failures.
      final isNetwork = e.toString().contains('SocketException') || e.toString().contains('Network');
      if (isNetwork) {
        onError(ApiError(
          title: 'No internet',
          message: 'Please check your internet connection',
          isNetworkError: true,
          alertActionButton: 'Retry',
          retryAction: () => fetch(api, parameters, onResponse, onError),
        ));
      } else {
        onError(ApiError(title: 'Server response', message: e.toString(), alertActionButton: 'Ok'));
      }
    }
  }

  /// Future-based convenience wrapper around [fetch], for idiomatic
  /// async/await use from ViewModels. Throws [ApiError] on failure.
  static Future<Map<String, dynamic>> request(ApiEndpoint api, [Map<String, dynamic>? parameters]) {
    final completer = Completer<Map<String, dynamic>>();
    fetch(api, parameters, completer.complete, (e) {
      if (!completer.isCompleted) completer.completeError(e);
    });
    return completer.future;
  }

  static void _handleApiError({
    required int statusCode,
    required String? message,
    required ApiEndpoint api,
    required Map<String, dynamic>? parameters,
    required void Function(Map<String, dynamic>) onResponse,
    required void Function(ApiError) onError,
  }) {
    final isExpiredToken = statusCode == 401 ||
        message == 'Invalid or expired token' ||
        message == 'Invalid or expired token.' ||
        message == 'Unauthorized';

    if (isExpiredToken) {
      removeRequestTokenAxios();
      unawaited(StorageService.instance.clearAll());
      onSessionExpired?.call();
      return; // stop further execution, same as the RN early-return.
    }

    onError(ApiError(
      title: 'Server response',
      message: message ?? 'Something went wrong',
      alertActionButton: 'Ok',
      statusCode: statusCode,
    ));
  }

  static Uri _buildUri(String path, Map<String, dynamic>? query) {
    final full = AppConstant.apiUrl + (path.startsWith('/') ? path.substring(1) : path);
    final uri = Uri.parse(full);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query.map((k, v) => MapEntry(k, v.toString())),
    });
  }
}

/// Port of the `@react-native-firebase/auth` phone sign-in calls used in
/// `PhoneScreen` / `OtpScreen` / `ChangePhoneScreen` / `ChangeOtpScreen`
/// (`signInWithPhoneNumber`, `confirmation.confirm`).
///
/// Firebase here is used purely as a phone-ownership verification gate,
/// exactly like in the RN app - once [confirmCode] returns `true`, the app's
/// own backend session/token (see `AuthViewModel.completeLogin`) is what
/// actually drives login state. No Firebase ID token is sent to the backend.
abstract class PhoneAuthService {
  /// `signInWithPhoneNumber(auth, phoneNumber)` - returns an opaque
  /// confirmation handle that [confirmCode] later uses.
  Future<Object?> sendCode(String phoneNumber);

  /// `confirmation.confirm(otpCode)`
  Future<bool> confirmCode(Object confirmation, String code);
}

/// Set to `true` once `Firebase.initializeApp()` succeeds in `main()`. Until
/// you drop in `google-services.json` / `GoogleService-Info.plist`,
/// `initializeFirebaseIfConfigured()` fails gracefully and the app falls back
/// to [PhoneAuthServiceStub] instead of crashing on boot.
bool firebaseReady = false;

/// Call once, before `runApp`, from `main()`.
Future<void> initializeFirebaseIfConfigured() async {
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    firebaseReady = false;
    debugPrint(
      'Firebase not configured yet (no google-services.json / GoogleService-Info.plist found), '
          'falling back to PhoneAuthServiceStub for phone verification. Error: $e',
    );
  }
}

/// Picks the real Firebase-backed service when available, otherwise the stub.
/// Call this from each phone/OTP screen instead of constructing either class
/// directly, so screens don't need to know which one is active.
PhoneAuthService createPhoneAuthService() {
  return firebaseReady ? FirebasePhoneAuthService() : const PhoneAuthServiceStub();
}

/// Real implementation, backed by `firebase_auth`.
class FirebasePhoneAuthService implements PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Object?> sendCode(String phoneNumber) async {
    final completer = Completer<Object?>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        // Android-only fast path: SMS auto-retrieved without the user typing a
        // code. We hand back the credential itself as the "confirmation
        // handle" - confirmCode() below recognizes a PhoneAuthCredential and
        // signs in with it directly, skipping manual OTP entry.
        verificationCompleted: (PhoneAuthCredential credential) {
          if (!completer.isCompleted) completer.complete(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Firebase phone verification failed: ${e.code} ${e.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // No-op: `codeSent` will already have resolved the completer above
          // in the normal (manual entry) flow by the time this fires.
        },
      );
    } catch (e) {
      debugPrint('Firebase verifyPhoneNumber error: $e');
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future;
  }

  @override
  Future<bool> confirmCode(Object confirmation, String code) async {
    try {
      final PhoneAuthCredential credential;
      if (confirmation is PhoneAuthCredential) {
        credential = confirmation;
      } else if (confirmation is String) {
        credential = PhoneAuthProvider.credential(verificationId: confirmation, smsCode: code);
      } else {
        return false;
      }

      await _auth.signInWithCredential(credential);
      // Firebase is only a verification gate here - the app's real session
      // token comes from the backend, so we don't keep a Firebase session around.
      await _auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase OTP confirm failed: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Firebase OTP confirm error: $e');
      return false;
    }
  }
}

/// Fallback used until Firebase config files are added - any 6-digit code is
/// accepted, so the flow stays navigable during development.
class PhoneAuthServiceStub implements PhoneAuthService {
  const PhoneAuthServiceStub();

  @override
  Future<Object?> sendCode(String phoneNumber) async => phoneNumber;

  @override
  Future<bool> confirmCode(Object confirmation, String code) async => code.length == 6;
}