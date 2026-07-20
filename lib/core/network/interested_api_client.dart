import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'interested_api_request.dart';

/// Thrown by [InterestedApiClient.fetch] on any failure (network, non-2xx,
/// bad JSON). Exposes `.message` the same way the RN `err?.message` pattern
/// does, so call sites can keep writing `err.message` unchanged.
///
/// Renamed from `ApiException` to avoid any ambiguity with the project's
/// existing `ApiError` class used by its real `ApiManager` / `Api_Manager`.
class InterestedApiException implements Exception {
  final String message;
  final int? statusCode;
  InterestedApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class InterestedApiClient {
  InterestedApiClient._();

  static String? authToken;

  static Map<String, String> _headers(Map<String, String> base) => {
        ...base,
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };
  static void fetch(
    InterestedApiRequest service,
    Map<String, dynamic> params,
    void Function(Map<String, dynamic> response) onSuccess,
    void Function(InterestedApiException error) onError,
  ) {
    request(service, params).then(onSuccess).catchError((e) {
      onError(e is InterestedApiException ? e : InterestedApiException(e.toString()));
    });
  }

  /// Future-based fetch for use with `await` / Provider-friendly async code.
  static Future<Map<String, dynamic>> request(
    InterestedApiRequest service,
    Map<String, dynamic> params,
  ) async {
    final uri = Uri.parse('${AppConstants.baseUrl}${service.path}');
    late http.Response response;

    try {
      if (service.method.toUpperCase() == 'GET') {
        response = await http.get(uri, headers: _headers(service.headers));
      } else {
        response = await http.post(
          uri,
          headers: _headers(service.headers),
          body: jsonEncode(params),
        );
      }
    } catch (e) {
      throw InterestedApiException('Network error. Please check your connection.');
    }

    Map<String, dynamic> decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw InterestedApiException('Unexpected server response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InterestedApiException(
        decoded['message']?.toString() ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
