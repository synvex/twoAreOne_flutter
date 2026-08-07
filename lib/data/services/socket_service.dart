import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Callback signature for socket listeners. Mirrors RN's
/// `addListener((data) => ...)` from ChatSocketProvider.js.
typedef SocketListener = void Function(Map<String, dynamic> data);

/// Global singleton WebSocket connection — the Flutter equivalent of
/// RN's ChatSocketProvider, which is mounted once at the app root and
/// shared by every screen via useGlobalSocket().
///
/// This is intentionally NOT a ChangeNotifier/Provider: in the RN app
/// there is exactly one socket for the whole app lifetime, independent
/// of which screen is mounted. A singleton is the direct equivalent.
class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();

  static const String _socketUrl = "wss://twoareone.love/ws";

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _isConnected = false;
  bool _isConnecting = false;

  final Set<SocketListener> _listeners = {};

  /// Mirrors RN's `onlineUsers` Set<string> of user ids.
  /// Wire your PresenceService to listen to this (see notes below).
  final ValueNotifier<Set<String>> onlineUsers = ValueNotifier<Set<String>>(
    <String>{},
  );

  bool get isConnected => _isConnected;

  /// Connects using the currently stored auth_token, same source
  /// ChatService already reads from SharedPreferences.
  /// Safe to call repeatedly — mirrors RN's "already open" guard.
  Future<void> connect() async {
    if (_isConnected || _isConnecting) {
      debugPrint("⚠️ Socket already connecting/connected");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token == null || _token!.isEmpty) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _isConnecting = true;
    debugPrint("🟢 Connecting socket...");

    try {
      final channel = WebSocketChannel.connect(Uri.parse(_socketUrl));
      // Wait for the handshake to complete — this is the Flutter
      // equivalent of RN's socket.onopen.
      await channel.ready;

      _channel = channel;
      _isConnected = true;
      _isConnecting = false;
      debugPrint("✅ Socket connected");

      _subscription = channel.stream.listen(
        _onMessage,
        onDone: _onClosed,
        onError: (e) {
          debugPrint("❌ Socket error: $e");
          channel.sink.close();
        },
        cancelOnError: true,
      );

      // Same first frame RN sends on open.
      sendMessage({"action": "auth", "token": _token});
    } catch (e) {
      debugPrint("❌ Socket init error: $e");
      _isConnected = false;
      _isConnecting = false;
      _channel = null;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final action = data['action'];

    if (action == 'online_users') {
      final users = (data['users'] as List? ?? [])
          .map((e) => e.toString())
          .toSet();
      onlineUsers.value = users;
      return;
    }

    if (action == 'user_online') {
      onlineUsers.value = {...onlineUsers.value, data['user_id'].toString()};
      return;
    }

    if (action == 'user_offline') {
      final next = {...onlineUsers.value};
      next.remove(data['user_id'].toString());
      onlineUsers.value = next;
      return;
    }

    // Everything else (new_message, counts_update, etc.) goes to
    // whoever is currently subscribed — same as RN's listenersRef fan-out.
    for (final listener in List<SocketListener>.from(_listeners)) {
      listener(data);
    }
  }

  void _onClosed() {
    debugPrint("🔴 Socket closed");
    _isConnected = false;
    _isConnecting = false;
    _channel = null;

    // RN only auto-reconnects while a token is still set (i.e. user is
    // still logged in) — same flat 2s delay, no backoff.
    if (_token != null && _token!.isNotEmpty) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), connect);
  }

  /// Manual disconnect — call this on logout, same as RN's disconnectSocket().
  /// Do NOT call this when merely leaving the chat screen.
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _token = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    onlineUsers.value = <String>{};
  }

  /// Public "force a fresh connection" entry point — RN calls this
  /// from useFocusEffect(() => reconnect()) whenever ChatScreen gains focus.
  Future<void> reconnect() => connect();

  /// Returns false if the socket isn't open, exactly like RN's
  /// sendMessage(), so callers can react (mark bubble as failed, reconnect).
  bool sendMessage(Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (e) {
      debugPrint("❌ Send failed: $e");
      return false;
    }
  }

  /// Returns an unsubscribe function — mirrors RN's addListener() return value.
  VoidCallback addListener(SocketListener cb) {
    _listeners.add(cb);
    return () => _listeners.remove(cb);
  }
}
