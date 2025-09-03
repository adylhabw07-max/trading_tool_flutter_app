import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/signal_provider.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalProvider>(
      builder: (context, signalProvider, child) {
        final isConnected = signalProvider.isConnected;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
            border: Border(
              bottom: BorderSide(
                color: isConnected ? Colors.green.shade200 : Colors.red.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'متصل - الإشارات المباشرة نشطة' : 'غير متصل - جاري المحاولة...',
                style: TextStyle(
                  color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isConnected)
                Icon(
                  Icons.wifi,
                  color: Colors.green.shade600,
                  size: 16,
                )
              else
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

