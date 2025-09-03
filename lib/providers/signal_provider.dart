import 'package:flutter/material.dart';
import '../models/signal.dart';
import '../services/api_service.dart';
import '../services/ws_service.dart';

class SignalProvider extends ChangeNotifier {
  List<Signal> _signals = [];
  bool _isLoading = false;
  String? _error;
  final WsService _wsService = WsService();
  Map<String, dynamic>? _appInfo;
  Map<String, dynamic>? _stats;

  List<Signal> get signals => _signals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _wsService.isConnected;
  Map<String, dynamic>? get appInfo => _appInfo;
  Map<String, dynamic>? get stats => _stats;

  SignalProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSignals();
    await loadAppInfo();
    await loadStats();
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      await _wsService.connect();
      
      // الاستماع للإشارات الجديدة
      _wsService.signalsStream.listen((signal) {
        _addNewSignal(signal);
      });
      
      // الاستماع للرسائل
      _wsService.messagesStream.listen((message) {
        print("رسالة WebSocket: ${message['message']}");
      });
      
    } catch (e) {
      print("خطأ في اتصال WebSocket: $e");
    }
  }

  void _addNewSignal(Signal signal) {
    // إضافة الإشارة الجديدة في المقدمة
    _signals.insert(0, signal);
    
    // الاحتفاظ بآخر 100 إشارة فقط
    if (_signals.length > 100) {
      _signals = _signals.take(100).toList();
    }
    
    notifyListeners();
  }

  Future<void> loadSignals({int limit = 20}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final signals = await ApiService.fetchLatestSignals(limit: limit);
      _signals = signals;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHistory({int limit = 100}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final signals = await ApiService.fetchSignalsHistory(limit: limit);
      _signals = signals;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAppInfo() async {
    try {
      _appInfo = await ApiService.fetchAppInfo();
      notifyListeners();
    } catch (e) {
      print("خطأ في جلب معلومات التطبيق: $e");
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await ApiService.fetchSignalsStats();
      notifyListeners();
    } catch (e) {
      print("خطأ في جلب الإحصائيات: $e");
    }
  }

  Future<Signal?> analyzeSymbol(String symbol, {String timeframe = "5m"}) async {
    try {
      final signal = await ApiService.analyzeSymbol(symbol, timeframe: timeframe);
      return signal;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<List<String>> getAvailablePairs() async {
    try {
      return await ApiService.fetchAvailablePairs();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentPrice(String symbol) async {
    try {
      return await ApiService.fetchCurrentPrice(symbol);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> checkConnection() async {
    try {
      await ApiService.checkHealth();
      return true;
    } catch (e) {
      _setError("لا يمكن الاتصال بالخادم");
      return false;
    }
  }

  void subscribeToPair(String pair) {
    _wsService.subscribeToPair(pair);
  }

  void requestLatestSignals() {
    _wsService.requestLatestSignals();
  }

  List<Signal> getSignalsByPair(String pair) {
    return _signals.where((signal) => signal.pair == pair).toList();
  }

  List<Signal> getBuySignals() {
    return _signals.where((signal) => signal.side == 1).toList();
  }

  List<Signal> getSellSignals() {
    return _signals.where((signal) => signal.side == -1).toList();
  }

  List<Signal> getHighConfidenceSignals({double minConfidence = 80.0}) {
    return _signals.where((signal) => signal.confidence >= minConfidence).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}

