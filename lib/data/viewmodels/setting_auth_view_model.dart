import 'package:flutter/foundation.dart';

import '../api_endpoints.dart';
import '../models/credential_change_user_model.dart';
import '../repo/settings_Api_services.dart';
import '../repo/socket_service.dart';
import '../repo/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._socketService);

  final SocketService _socketService;

  // ---------------- authReducer.js initialState ----------------
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  UserModel? _user;
  String? _token;
  String _shownScreen = '0';
  bool _refreshing = false;
  bool _exploreRefresh = false;
  Map<String, dynamic>? _coordinates;
  bool _refreshQuestion = false;
  bool _refreshProfile = false;
  String? _readChatUserId;
  dynamic _lastProfileAction;
  dynamic _confirmation;
  dynamic _customerId; // setWithoutLoginUser

  /// Extra vs. the RN state: drives the "show loader until boot is complete"
  /// requirement from `Navigator/index.js` (`bootDone` local state there).
  bool _bootDone = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get user => _user;
  String? get token => _token;
  String get shownScreen => _shownScreen;
  bool get refreshing => _refreshing;
  bool get exploreRefresh => _exploreRefresh;
  Map<String, dynamic>? get coordinates => _coordinates;
  bool get refreshQuestion => _refreshQuestion;
  bool get refreshProfile => _refreshProfile;
  String? get readChatUserId => _readChatUserId;
  dynamic get lastProfileAction => _lastProfileAction;
  dynamic get confirmation => _confirmation;
  dynamic get customerId => _customerId;
  bool get bootDone => _bootDone;

  // ---------------- action creators (authSlice.reducers) ----------------

  void logIn(Map<String, dynamic> payload) {
    _currentUser = UserModel(payload);
    _isLoggedIn = true;
    notifyListeners();
  }

  void setScreen(String screen) {
    _shownScreen = screen;
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    _socketService.updateToken(token);
    notifyListeners();
  }

  void setReadChatUserId(String? id) {
    _readChatUserId = id;
    notifyListeners();
  }

  void clearReadChatUserId() {
    _readChatUserId = null;
    notifyListeners();
  }

  void setConfirmation(dynamic value) {
    _confirmation = value;
    notifyListeners();
  }

  void setRefreshQuestion(bool value) {
    _refreshQuestion = value;
    notifyListeners();
  }

  void setRefreshProfile(bool value) {
    _refreshProfile = value;
    notifyListeners();
  }

  void clearConfirmation() {
    _confirmation = null;
    notifyListeners();
  }

  void setUser(Map<String, dynamic> payload) {
    _user = UserModel(payload);
    notifyListeners();
  }

  void setRefresh(bool payload) {
    _refreshing = payload;
    notifyListeners();
  }

  void setExploreRefresh(bool payload) {
    _exploreRefresh = payload;
    notifyListeners();
  }

  /// NOTE: faithfully ported bug from `authReducer.js` -
  /// `setCoordinates` there sets `state.refreshing`, not `state.coordinates`.
  /// Kept as-is per "exact same functionality" requirement.
  void setCoordinates(bool payload) {
    _refreshing = payload;
    notifyListeners();
  }

  void setProfileAction(dynamic payload) {
    _lastProfileAction = payload;
    notifyListeners();
  }

  void clearProfileAction() {
    _lastProfileAction = null;
    notifyListeners();
  }

  /// `LogOut` reducer.
  void logOut() {
    _currentUser = null;
    _isLoggedIn = false;
    _user = null;
    _token = null;
    ApiService.removeRequestTokenAxios();
    _socketService.updateToken(null);
    notifyListeners();
  }

  void setWithoutLoginUser(dynamic payload) {
    _customerId = payload;
    notifyListeners();
  }

  // ---------------- boot flow (Navigator/index.js) ----------------

  /// Read stored token/user, restore auth state, configure API auth headers,
  /// and fetch fresh user info - identical sequence to `boot()` in
  /// `Navigator/index.js`. Always leaves `bootDone = true` in the `finally`,
  /// which is what lets the UI stop showing the loader.
  Future<void> boot() async {
    try {
      final token = await StorageService.instance.fetch(StorageKeys.accessToken);
      final userInfoRaw = await StorageService.instance.fetchObject(StorageKeys.userInfo);

      if (token != null && userInfoRaw != null) {
        logIn(userInfoRaw);
        setToken(token);
        ApiService.setUpRequestTokenAxios(token);

        // wait for real user info before rendering the app, like the RN code does.
        await _fetchUserInfo(token);
      }
    } catch (e) {
      debugPrint('Boot error: $e');
    } finally {
      _bootDone = true;
      notifyListeners();
    }
  }

  Future<void> completeLogin(Map<String, dynamic> userData) async {
    final token = userData['api_token']?.toString();
    await StorageService.instance.saveValue(StorageKeys.accessToken, token ?? '');
    await StorageService.instance.saveObject(StorageKeys.userInfo, userData);
    await StorageService.instance.saveValue(StorageKeys.isAlreadyLogin, 'true');

    logIn(userData);
    if (token != null) {
      ApiService.setUpRequestTokenAxios(token);
      setToken(token);
      await _fetchUserInfo(token);
    }
  }
  Future<void> advanceScreen(String screen) async {
    await StorageService.instance.saveValue(StorageKeys.screenType, screen);
    setScreen(screen);
  }

  Future<void> _fetchUserInfo(String token) async {
    try {
      final data = await ApiService.request(ApiEndpoints.getUserInfo);

      if (data['message'] == 'Invalid or expired token.') {
        await StorageService.instance.clearAll();
        logOut();
        return;
      }

      final userData = data['data'];
      if (userData is Map<String, dynamic>) {
        setUser(userData);

        final user = UserModel(userData);
        final nextScreen = user.completeQuestion == 'true' ? '3' : user.screenType;

        setScreen(nextScreen);
        await StorageService.instance.saveValue(StorageKeys.screenType, nextScreen);
      }
    } catch (e) {
      debugPrint('Fetch user error: $e');
    }
  }
}