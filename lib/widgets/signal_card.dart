import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/signal.dart';

class SignalCard extends StatefulWidget {
  final Signal signal;
  final VoidCallback? onTap;

  const SignalCard({
    super.key,
    required this.signal,
    this.onTap,
  });

  @override
  State<SignalCard> createState() => _SignalCardState();
}

class _SignalCardState extends State<SignalCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _remainingSeconds = widget.signal.waitSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_remainingSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
          _startCountdown();
        }
      });
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.signal.sideEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.signal.pair,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.signal.sideText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.signal.confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDetailItem(
                icon: Icons.schedule,
                label: 'الإطار الزمني',
                value: widget.signal.timeframe,
              ),
              const SizedBox(width: 16),
              if (widget.signal.currentPrice != null)
                _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'السعر',
                  value: widget.signal.currentPrice!.toStringAsFixed(5),
                ),
            ],
          ),
          if (widget.signal.support != null || widget.signal.resistance != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.signal.support != null)
                  _buildDetailItem(
                    icon: Icons.trending_down,
                    label: 'الدعم',
                    value: widget.signal.support!.toStringAsFixed(5),
                  ),
                const SizedBox(width: 16),
                if (widget.signal.resistance != null)
                  _buildDetailItem(
                    icon: Icons.trending_up,
                    label: 'المقاومة',
                    value: widget.signal.resistance!.toStringAsFixed(5),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'وقت الدخول:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final timestamp = DateTime.tryParse(widget.signal.ts);
    final timeString = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toLocal())
        : '';

    return Row(
      children: [
        if (widget.signal.reasons != null && widget.signal.reasons!.isNotEmpty)
          Expanded(
            child: Text(
              widget.signal.reasons!.first.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          timeString,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradient() {
    switch (widget.signal.side) {
      case 1: // شراء
        return LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case -1: // بيع
        return LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default: // انتظار
        return LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getAccentColor() {
    switch (widget.signal.side) {
      case 1:
        return Colors.green;
      case -1:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getAccentColor().withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildDetails(),
                      if (_remainingSeconds > 0) ...[
                        const SizedBox(height: 12),
                        _buildCountdown(),
                      ],
                      const SizedBox(height: 8),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


