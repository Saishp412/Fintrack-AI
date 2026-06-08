import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics_provider.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/daily_trend_line_chart.dart';
import 'widgets/income_expense_comparison_chart.dart';
import 'widgets/category_breakdown_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../data/pdf_service.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../ai_insights/data/ai_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () async {
              final provider = Provider.of<AnalyticsProvider>(context, listen: false);
              final authProv = Provider.of<AuthProvider>(context, listen: false);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              // Fetch AI Summary
              final aiService = AIService();
              final aiSummary = await aiService.generatePdfSummary(
                income: provider.transactionProvider.totalIncome,
                expense: provider.transactionProvider.totalExpense,
                topCategory: provider.highestSpendingCategory,
                role: authProv.user?.role ?? 'professional',
              );

              if (context.mounted) {
                Navigator.pop(context); // close loading dialog
              }

              await PdfService.generateAndPrintMonthlyReport(
                income: provider.transactionProvider.totalIncome,
                expense: provider.transactionProvider.totalExpense,
                transactions: provider.transactionProvider.transactions,
                aiSummary: aiSummary,
              );
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildHighlightCard(
                        context, 
                        'Savings Rate', 
                        '${provider.savingsRate.toStringAsFixed(1)}%', 
                        Icons.percent
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildHighlightCard(
                        context, 
                        'Daily Average', 
                        '₹${provider.averageDailySpending.toStringAsFixed(0)}', 
                        Icons.calendar_today
                      ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Highest Spending Category', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        provider.highestSpendingCategory,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),

                // Pie Chart
                Text('Expense Distribution', style: Theme.of(context).textTheme.titleLarge)
                    .animate().fade(duration: 400.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 24),
                const ExpensePieChart()
                    .animate().fade(duration: 600.ms, delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 40),

                // Advanced Charts Phase 12
                DailyTrendLineChart(transactions: provider.transactionProvider.transactions)
                    .animate().fade(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 40),
                
                IncomeExpenseComparisonChart(
                  income: provider.transactionProvider.totalIncome,
                  expense: provider.transactionProvider.totalExpense,
                ).animate().fade(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 40),

                CategoryBreakdownChart(categoryTotals: provider.expensesByCategory)
                    .animate().fade(duration: 600.ms, delay: 700.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
