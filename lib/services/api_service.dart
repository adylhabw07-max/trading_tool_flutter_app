import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signal.dart';

class ApiService {
  // رابط الخادم المنشور
  static const String baseUrl = "https://8000-i0dcytxdn3178nvpc2o7r-969bcf2c.manusvm.computer";
  
  static const Duration timeout = Duration(seconds: 15);

  static Future<List<Signal>> fetchLatestSignals({int limit = 10, String? pair}) async {
    try {
      final uri = Uri.parse("$baseUrl/signals/latest")
          .replace(queryParameters: {
            'limit': limit.toString(),
            if (pair != null) 'pair': pair,
          });

      final response = await http.get(uri).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Signal.fromJson(json)).toList();
      } else {
        throw Exception("فشل في جلب الإشارات: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<List<Signal>> fetchSignalsHistory({int limit = 100, String? pair}) async {
    try {
      final uri = Uri.parse("$baseUrl/signals/history")
          .replace(queryParameters: {
            'limit': limit.toString(),
            if (pair != null) 'pair': pair,
          });

      final response = await http.get(uri).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Signal.fromJson(json)).toList();
      } else {
        throw Exception("فشل في جلب السجل: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<Signal> analyzeSymbol(String symbol, {String timeframe = "5m"}) async {
    try {
      final uri = Uri.parse("$baseUrl/signals/analyze/$symbol")
          .replace(queryParameters: {'timeframe': timeframe});

      final response = await http.get(uri).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Signal.fromJson(data);
      } else {
        throw Exception("فشل في تحليل الرمز: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في التحليل: $e");
    }
  }

  static Future<List<String>> fetchAvailablePairs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/signals/pairs")).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception("فشل في جلب الأزواج: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<Map<String, dynamic>> fetchSignalsStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/signals/stats")).timeout(timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("فشل في جلب الإحصائيات: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOHLC(
    String symbol, {
    String timeframe = "5m",
    int limit = 50,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/ohlc/")
          .replace(queryParameters: {
            'symbol': symbol,
            'timeframe': timeframe,
            'limit': limit.toString(),
          });

      final response = await http.get(uri).timeout(timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("فشل في جلب بيانات OHLC: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentPrice(String symbol) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/ohlc/current_price/$symbol")).timeout(timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("فشل في جلب السعر: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/health")).timeout(timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("الخادم غير متاح: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال بالخادم: $e");
    }
  }

  static Future<Map<String, dynamic>> fetchAppInfo() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/info")).timeout(timeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("فشل في جلب معلومات التطبيق: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }
}

