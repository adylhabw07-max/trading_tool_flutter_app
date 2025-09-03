import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/signal_provider.dart';
import '../widgets/signal_card.dart';
import '../widgets/connection_status.dart';
import '../widgets/stats_card.dart';
import 'signal_detail_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أداة التحليل التقني المتقدمة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'الإشارات'),
            Tab(icon: Icon(Icons.analytics), text: 'التحليل'),
            Tab(icon: Icon(Icons.bar_chart), text: 'الإحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSignalsTab(),
          const AnalysisScreen(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return Consumer<SignalProvider>(
      builder: (context, signalProvider, child) {
        return Column(
          children: [
            // شريط الحالة
            const ConnectionStatus(),
            
            // أزرار التحكم
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: signalProvider.isLoading 
                          ? null 
                          : () => signalProvider.loadSignals(),
                      icon: signalProvider.isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(signalProvider.isLoading ? 'جاري التحديث...' : 'تحديث'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => signalProvider.requestLatestSignals(),
                    icon: const Icon(Icons.wifi),
                    label: const Text('طلب إشارات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // رسالة الخطأ
            if (signalProvider.error != null)
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        signalProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      onPressed: signalProvider.clearError,
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            
            // قائمة الإشارات
            Expanded(
              child: signalProvider.signals.isEmpty
                  ? _buildEmptyState(signalProvider.isLoading)
                  : RefreshIndicator(
                      onRefresh: () => signalProvider.loadSignals(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: signalProvider.signals.length,
                        itemBuilder: (context, index) {
                          final signal = signalProvider.signals[index];
                          return SignalCard(
                            signal: signal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignalDetailScreen(signal: signal),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer<SignalProvider>(
      builder: (context, signalProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات التطبيق
              if (signalProvider.appInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          signalProvider.appInfo!['app_name'] ?? 'أداة التحليل التقني',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          signalProvider.appInfo!['description'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text('الإصدار: ${signalProvider.appInfo!['version'] ?? '2.0.0'}'),
                        Text('عملاء WebSocket: ${signalProvider.appInfo!['websocket_clients'] ?? 0}'),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // إحصائيات الإشارات
              if (signalProvider.stats != null)
                StatsCard(stats: signalProvider.stats!),
              
              const SizedBox(height: 16),
              
              // الأزواج المدعومة
              if (signalProvider.appInfo != null && 
                  signalProvider.appInfo!['supported_pairs'] != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الأزواج المدعومة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: (signalProvider.appInfo!['supported_pairs'] as List)
                              .map((pair) => Chip(
                                    label: Text(pair),
                                    backgroundColor: Colors.blue.shade50,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // الميزات
              if (signalProvider.appInfo != null && 
                  signalProvider.appInfo!['features'] != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الميزات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(signalProvider.appInfo!['features'] as Map<String, dynamic>)
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        entry.value == true 
                                            ? Icons.check_circle 
                                            : Icons.info,
                                        color: entry.value == true 
                                            ? Colors.green 
                                            : Colors.blue,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.key.replaceAll('_', ' '),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      if (entry.value is String)
                                        Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الإشارات...'),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشارات متاحة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على تحديث لجلب أحدث الإشارات',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

