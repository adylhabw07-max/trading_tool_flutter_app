class Signal {
  final int id;
  final String pair;
  final int side; // 1 = BUY, -1 = SELL, 0 = WAIT
  final double confidence;
  final String timeframe;
  final String ts;
  final Map<String, dynamic>? entry;
  final List<dynamic>? reasons;
  final Map<String, dynamic>? indicators;
  final int? score;
  final DateTime? createdAt;

  Signal({
    required this.id,
    required this.pair,
    required this.side,
    required this.confidence,
    required this.timeframe,
    required this.ts,
    this.entry,
    this.reasons,
    this.indicators,
    this.score,
    this.createdAt,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'] ?? 0,
      pair: json['pair'] ?? '',
      side: json['side'] ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      timeframe: json['timeframe'] ?? '',
      ts: json['ts'] ?? '',
      entry: json['entry'] as Map<String, dynamic>?,
      reasons: json['reasons'] as List<dynamic>?,
      indicators: json['indicators'] as Map<String, dynamic>?,
      score: json['score'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pair': pair,
      'side': side,
      'confidence': confidence,
      'timeframe': timeframe,
      'ts': ts,
      'entry': entry,
      'reasons': reasons,
      'indicators': indicators,
      'score': score,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get sideText {
    switch (side) {
      case 1:
        return 'شراء';
      case -1:
        return 'بيع';
      default:
        return 'انتظار';
    }
  }

  String get sideEmoji {
    switch (side) {
      case 1:
        return '🟢';
      case -1:
        return '🔴';
      default:
        return '🟡';
    }
  }

  int get waitSeconds {
    return entry?['wait_seconds'] ?? 0;
  }

  double? get currentPrice {
    return entry?['current_price']?.toDouble();
  }

  double? get support {
    return entry?['support']?.toDouble();
  }

  double? get resistance {
    return entry?['resistance']?.toDouble();
  }
}

