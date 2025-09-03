import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/signal.dart';

class WsService {
  // رابط WebSocket المنشور
  static const String wsUrl = "wss://8000-i0dcytxdn3178nvpc2o7r-969bcf2c.manusvm.computer/ws/";
  
  WebSocketChannel? _channel;
  StreamController<Signal>? _signalsController;
  StreamController<Map<String, dynamic>>? _messagesController;
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  Stream<Signal> get signalsStream => _signalsController?.stream ?? const Stream.empty();
  Stream<Map<String, dynamic>> get messagesStream => _messagesController?.stream ?? const Stream.empty();
  
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      await disconnect(); // قطع أي اتصال سابق
      
      _signalsController = StreamController<Signal>.broadcast();
      _messagesController = StreamController<Map<String, dynamic>>.broadcast();
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // الاستماع للرسائل
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _isConnected = true;
      print("✅ تم الاتصال بـ WebSocket");
      
      // بدء heartbeat
      _startHeartbeat();
      
      // طلب أحدث الإشارات
      requestLatestSignals();
      
    } catch (e) {
      print("❌ خطأ في الاتصال بـ WebSocket: $e");
      _isConnected = false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'] ?? '';
      
      switch (messageType) {
        case 'new_signal':
          if (data['data'] != null) {
            final signal = Signal.fromJson(data['data']);
            _signalsController?.add(signal);
            print("📡 إشارة جديدة: ${signal.pair} ${signal.sideText}");
          }
          break;
          
        case 'latest_signals':
          if (data['data'] != null) {
            final List<dynamic> signalsData = data['data'];
            for (var signalData in signalsData) {
              final signal = Signal.fromJson(signalData);
              _signalsController?.add(signal);
            }
            print("📊 تم استلام ${signalsData.length} إشارة");
          }
          break;
          
        case 'welcome':
        case 'pong':
        case 'subscribed':
        case 'error':
          _messagesController?.add(data);
          print("💬 رسالة: ${data['message']}");
          break;
          
        default:
          print("❓ رسالة غير معروفة: $messageType");
      }
    } catch (e) {
      print("❌ خطأ في معالجة الرسالة: $e");
    }
  }

  void _handleError(error) {
    print("❌ خطأ WebSocket: $error");
    _isConnected = false;
    _reconnect();
  }

  void _handleDisconnection() {
    print("🔌 انقطع الاتصال بـ WebSocket");
    _isConnected = false;
    _reconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        sendMessage({"type": "ping", "message": "heartbeat"});
      }
    });
  }

  void _reconnect() {
    if (!_isConnected) {
      print("🔄 محاولة إعادة الاتصال...");
      Future.delayed(const Duration(seconds: 5), () {
        connect();
      });
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print("❌ خطأ في إرسال الرسالة: $e");
      }
    }
  }

  void requestLatestSignals() {
    sendMessage({"type": "get_latest"});
  }

  void subscribeToPair(String pair) {
    sendMessage({"type": "subscribe", "pair": pair});
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    
    await _signalsController?.close();
    await _messagesController?.close();
    
    _signalsController = null;
    _messagesController = null;
    _isConnected = false;
    
    print("👋 تم قطع الاتصال بـ WebSocket");
  }

  void dispose() {
    disconnect();
  }
}

