import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_constants.dart';

/// Port of `src/hooks/ChatSocketProvider.js` (the `SocketProvider` context) +
/// the token-wiring done in `src/hooks/SocketProviderWrapper.js`.
///
/// Registered as a single app-wide `ChangeNotifier` (via `provider`) instead
/// of a React context - `AuthViewModel` calls [updateToken] whenever the auth
/// token changes, which is exactly the RN `useEffect(() => { ... }, [token])`
/// that tore down and reconnected the socket.
class SocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  String? _token;

  final Set<String> _onlineUsers = <String>{};
  final Set<void Function(Map<String, dynamic>)> _listeners = {};

  bool _isConnected = false;

  Set<String> get onlineUsers => Set.unmodifiable(_onlineUsers);
  bool get isConnected => _isConnected;

  /// `useGlobalSocket().addListener(cb)` -> returns an unsubscribe callback.
  void Function() addListener2(void Function(Map<String, dynamic>) callback) {
    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

  /// Called from `AuthViewModel` on login/logout/boot, mirrors the RN
  /// `useEffect(() => { disconnectSocket(); connectSocket(); }, [token])`.
  void updateToken(String? token) {
    _token = token;
    if (token == null) {
      _disconnect();
      _onlineUsers.clear();
      notifyListeners();
      return;
    }
    _disconnect();
    _connect();
  }

  void _connect() {
    if (_token == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final channel = WebSocketChannel.connect(Uri.parse(AppConstant.socketUrl));
      _channel = channel;

      channel.sink.add(jsonEncode({'action': 'auth', 'token': _token}));
      _isConnected = true;
      notifyListeners();

      _sub = channel.stream.listen(
        _onMessage,
        onDone: _onClosed,
        onError: (_) => _onClosed(),
        cancelOnError: true,
      );
    } catch (_) {
      _onClosed();
    }
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    switch (data['action']) {
      case 'online_users':
        _onlineUsers
          ..clear()
          ..addAll(((data['users'] as List?) ?? []).map((e) => e.toString()));
        notifyListeners();
        return;
      case 'user_online':
        _onlineUsers.add(data['user_id'].toString());
        notifyListeners();
        return;
      case 'user_offline':
        _onlineUsers.remove(data['user_id'].toString());
        notifyListeners();
        return;
      default:
        for (final cb in _listeners) {
          cb(data);
        }
    }
  }

  void _onClosed() {
    _isConnected = false;
    _channel = null;
    notifyListeners();
    if (_token != null) {
      _reconnectTimer = Timer(const Duration(seconds: 2), _connect);
    }
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sub?.cancel();
    _sub = null;
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
  }

  /// `sendMessage(payload)`
  bool sendMessage(Map<String, dynamic> payload) {
    if (_channel == null || !_isConnected) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// manual reconnect / disconnect, same as the RN context value.
  void reconnect() => _connect();
  void disconnect() => _disconnect();

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}
