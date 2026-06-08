import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../analytics/presentation/analytics_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/ai_service.dart';
import 'ai_chat_screen.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final AIService _aiService = AIService();
  bool _isLoading = true;
  String _aiResponse = '';

  @override
  void initState() {
    super.initState();
    // We must wait for the build phase to finish before accessing providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInsight();
    });
  }

  Future<void> _fetchInsight() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await _aiService.generateFinancialInsight(
      income: provider.transactionProvider.totalIncome,
      expense: provider.transactionProvider.totalExpense,
      topCategory: provider.highestSpendingCategory,
      role: authProv.user?.role ?? 'professional',
    );

    if (mounted) {
      setState(() {
        _aiResponse = response;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack AI Insights'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Chat with AI'),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          final isSpendingHigh = provider.averageDailySpending > 1000;
          final highestCat = provider.highestSpendingCategory;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Header Graphic
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, size: 64, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text('Generative AI Analysis', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // OpenAI Insight
                _isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ))
                    : _buildInsightCard(
                        context,
                        title: 'GPT-4o Mini Summary',
                        message: _aiResponse,
                        icon: Icons.psychology,
                        color: AppColors.primary,
                      ),
                
                const SizedBox(height: 32),
                Text('Metrics & Alerts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // Insight 2
                _buildInsightCard(
                  context,
                  title: 'Daily Average Alert',
                  message: isSpendingHigh 
                      ? 'You are spending ₹${provider.averageDailySpending.toStringAsFixed(0)} daily. This is higher than your historical average. Try to reduce non-essential spending this week.'
                      : 'Great job! Your daily spending of ₹${provider.averageDailySpending.toStringAsFixed(0)} is well within your safe limits.',
                  icon: isSpendingHigh ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: isSpendingHigh ? AppColors.error : AppColors.success,
                ),
                const SizedBox(height: 16),

                // Insight 3
                _buildInsightCard(
                  context,
                  title: 'Savings Opportunity',
                  message: 'Based on your current trajectory, if you cut your $highestCat expenses by 15%, you could reach your Emergency Fund goal 2 months faster.',
                  icon: Icons.lightbulb_outline,
                  color: AppColors.secondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String title, required String message, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: color)),
                const SizedBox(height: 8),
                Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
