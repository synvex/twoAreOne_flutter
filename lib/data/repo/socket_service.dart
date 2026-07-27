import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_constants.dart';

class SocketService extends ChangeNotifier {
  static final SocketService instance = SocketService._internal();
  SocketService._internal();
  factory SocketService() => instance;

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
  /// Named `addMessageListener` (not `addListener`) because `ChangeNotifier`
  /// already owns `addListener` for its own widget-rebuild subscribers -
  /// this is a separate mechanism for raw socket message events.
  void Function() addMessageListener(void Function(Map<String, dynamic>) callback) {
    _listeners.add(callback);
    return () => _listeners.remove(callback);
  }

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

    if (_isConnected && _channel != null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final channel = WebSocketChannel.connect(Uri.parse(AppConstant.socketUrl));
      _channel = channel;
      channel.ready.then((_) {
        if (_channel != channel) return; // superseded by a newer connect/disconnect
        channel.sink.add(jsonEncode({'action': 'auth', 'token': _token}));
        _isConnected = true;
        notifyListeners();
      }).catchError((_) {
        if (_channel == channel) _onClosed();
      });

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
      _channel!.sink.close(1000); // matches RN's socketRef.current.close(1000)
      _channel = null;
    }
    _isConnected = false;
  }
  bool sendMessage(Map<String, dynamic> payload) {
    if (_channel == null || !_isConnected) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (_) {
      return false;
    }
  }
  void reconnect() => _connect();
  void disconnect() => _disconnect();

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// import '../../core/constants/app_constants.dart';
//
// class SocketService extends ChangeNotifier {
//   WebSocketChannel? _channel;
//   StreamSubscription? _sub;
//   Timer? _reconnectTimer;
//   String? _token;
//
//   final Set<String> _onlineUsers = <String>{};
//   final Set<void Function(Map<String, dynamic>)> _listeners = {};
//
//   bool _isConnected = false;
//
//   Set<String> get onlineUsers => Set.unmodifiable(_onlineUsers);
//   bool get isConnected => _isConnected;
//
//   /// `useGlobalSocket().addListener(cb)` -> returns an unsubscribe callback.
//   void Function() addListener2(void Function(Map<String, dynamic>) callback) {
//     _listeners.add(callback);
//     return () => _listeners.remove(callback);
//   }
//
//   void updateToken(String? token) {
//     _token = token;
//     if (token == null) {
//       _disconnect();
//       _onlineUsers.clear();
//       notifyListeners();
//       return;
//     }
//     _disconnect();
//     _connect();
//   }
//
//   void _connect() {
//     if (_token == null) return;
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//
//     try {
//       final channel = WebSocketChannel.connect(Uri.parse(AppConstant.socketUrl));
//       _channel = channel;
//
//       channel.sink.add(jsonEncode({'action': 'auth', 'token': _token}));
//       _isConnected = true;
//       notifyListeners();
//
//       _sub = channel.stream.listen(
//         _onMessage,
//         onDone: _onClosed,
//         onError: (_) => _onClosed(),
//         cancelOnError: true,
//       );
//     } catch (_) {
//       _onClosed();
//     }
//   }
//
//   void _onMessage(dynamic raw) {
//     Map<String, dynamic>? data;
//     try {
//       data = jsonDecode(raw as String) as Map<String, dynamic>;
//     } catch (_) {
//       return;
//     }
//
//     switch (data['action']) {
//       case 'online_users':
//         _onlineUsers
//           ..clear()
//           ..addAll(((data['users'] as List?) ?? []).map((e) => e.toString()));
//         notifyListeners();
//         return;
//       case 'user_online':
//         _onlineUsers.add(data['user_id'].toString());
//         notifyListeners();
//         return;
//       case 'user_offline':
//         _onlineUsers.remove(data['user_id'].toString());
//         notifyListeners();
//         return;
//       default:
//         for (final cb in _listeners) {
//           cb(data);
//         }
//     }
//   }
//
//   void _onClosed() {
//     _isConnected = false;
//     _channel = null;
//     notifyListeners();
//     if (_token != null) {
//       _reconnectTimer = Timer(const Duration(seconds: 2), _connect);
//     }
//   }
//
//   void _disconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//     _sub?.cancel();
//     _sub = null;
//     if (_channel != null) {
//       _channel!.sink.close();
//       _channel = null;
//     }
//     _isConnected = false;
//   }
//
//   /// `sendMessage(payload)`
//   bool sendMessage(Map<String, dynamic> payload) {
//     if (_channel == null || !_isConnected) return false;
//     try {
//       _channel!.sink.add(jsonEncode(payload));
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   /// manual reconnect / disconnect, same as the RN context value.
//   void reconnect() => _connect();
//   void disconnect() => _disconnect();
//
//   @override
//   void dispose() {
//     _disconnect();
//     super.dispose();
//   }
// }
