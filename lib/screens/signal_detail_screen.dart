import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/signal.dart';

class SignalDetailScreen extends StatelessWidget {
  final Signal signal;

  const SignalDetailScreen({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(signal.pair),
        backgroundColor: _getAccentColor(),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getAccentColor(), _getAccentColor().withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                signal.sideEmoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              signal.pair,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              signal.sideText,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'الثقة: ${signal.confidence.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          if (signal.reasons != null && signal.reasons!.isNotEmpty)
            _buildReasonsCard(),
          const SizedBox(height: 16),
          if (signal.indicators != null && signal.indicators!.isNotEmpty)
            _buildIndicatorsCard(),
          const SizedBox(height: 16),
          _buildTimingCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final timestamp = DateTime.tryParse(signal.ts);
    final timeString = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toLocal())
        : signal.ts;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الإشارة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الزوج', signal.pair),
            _buildInfoRow('الإجراء', signal.sideText),
            _buildInfoRow('الثقة', '${signal.confidence.toStringAsFixed(1)}%'),
            _buildInfoRow('الإطار الزمني', signal.timeframe),
            _buildInfoRow('الوقت', timeString),
            if (signal.currentPrice != null)
              _buildInfoRow('السعر الحالي', signal.currentPrice!.toStringAsFixed(5)),
            if (signal.support != null)
              _buildInfoRow('الدعم', signal.support!.toStringAsFixed(5)),
            if (signal.resistance != null)
              _buildInfoRow('المقاومة', signal.resistance!.toStringAsFixed(5)),
            if (signal.score != null)
              _buildInfoRow('النقاط', signal.score.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أسباب التوصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...signal.reasons!.map((reason) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getAccentColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المؤشرات الفنية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...signal.indicators!.entries.map((entry) {
              String displayValue;
              if (entry.value is double) {
                displayValue = (entry.value as double).toStringAsFixed(2);
              } else if (entry.value is List) {
                displayValue = (entry.value as List).join(', ');
              } else {
                displayValue = entry.value.toString();
              }
              
              return _buildInfoRow(
                _getIndicatorLabel(entry.key),
                displayValue,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توقيت الدخول',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (signal.waitSeconds > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getAccentColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getAccentColor().withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _getAccentColor(),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'وقت الانتظار المقترح',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${signal.waitSeconds} ثانية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getAccentColor(),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'يمكن الدخول الآن',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getIndicatorLabel(String key) {
    switch (key) {
      case 'rsi':
        return 'RSI';
      case 'macd':
        return 'MACD';
      case 'trend':
        return 'الاتجاه';
      case 'trend_strength':
        return 'قوة الاتجاه';
      case 'patterns':
        return 'الأنماط';
      default:
        return key;
    }
  }

  Color _getAccentColor() {
    switch (signal.side) {
      case 1:
        return Colors.green;
      case -1:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

