import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PresenceService extends ChangeNotifier with WidgetsBindingObserver {
  static const String _socketUrl = "wss://twoareone.love/ws";

  PresenceService() {
    WidgetsBinding.instance.addObserver(this);
  }

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _connecting = false;

  final Set<String> _onlineUserIds = {};
  bool isConnected = false;

  bool isOnline(dynamic userId) => _onlineUserIds.contains(userId.toString());

  Future<void> connect() async {
    if (isConnected || _connecting) return;
    _connecting = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      _connecting = false;
      return;
    }

    _reconnectTimer?.cancel();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_socketUrl));
      await _channel!.ready;

      _channel!.sink.add(jsonEncode({"action": "auth", "token": token}));

      isConnected = true;
      _connecting = false;
      _startPing();

      _sub = _channel!.stream.listen(
        _handleMessage,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint("PresenceService connect error: $e");
      _connecting = false;
      _scheduleReconnect();
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      try {
        _channel?.sink.add(jsonEncode({"action": "ping"}));
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  void _handleMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw);
      switch (data['action']) {
        case 'online_users':
          _onlineUserIds
            ..clear()
            ..addAll((data['users'] as List).map((e) => e.toString()));
          break;
        case 'user_online':
          _onlineUserIds.add(data['user_id'].toString());
          break;
        case 'user_offline':
          _onlineUserIds.remove(data['user_id'].toString());
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("PresenceService parse error: $e");
    }
  }

  void _scheduleReconnect() {
    isConnected = false;
    _connecting = false;
    _pingTimer?.cancel();
    _onlineUserIds.clear();
    notifyListeners();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), connect);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
    _connecting = false;
    _onlineUserIds.clear();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      connect();
    } else if (state == AppLifecycleState.paused) {
      disconnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }
}
