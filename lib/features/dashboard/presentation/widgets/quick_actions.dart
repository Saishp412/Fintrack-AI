import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../transactions/presentation/add_transaction_screen.dart';
import '../../../analytics/presentation/analytics_screen.dart';
import '../../../ai_insights/presentation/ai_insights_screen.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../student/presentation/split_bills_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final isStudent = authProv.user?.role == 'student';

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionItem(context, 'Add Income', Icons.add_circle_outline, AppColors.success, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen(isIncome: true)));
        }),
        _buildActionItem(context, 'Add Expense', Icons.remove_circle_outline, AppColors.error, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen(isIncome: false)));
        }),
        _buildActionItem(context, 'Analytics', Icons.bar_chart, AppColors.secondary, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
        }),
        _buildActionItem(context, 'AI Insights', Icons.auto_awesome, AppColors.primary, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIInsightsScreen()));
        }),
        if (isStudent)
          _buildActionItem(context, 'Split Bills', Icons.call_split, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitBillsScreen()));
          }),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fade(duration: 400.ms);
  }
}
