import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../transactions/presentation/transaction_provider.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../student/presentation/student_provider.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final studentProv = Provider.of<StudentProvider>(context);
    
    final double monthlyIncome = provider.totalIncome;
    final double monthlyExpense = provider.totalExpense;
    final double totalBalance = monthlyIncome - monthlyExpense;
    final double savings = totalBalance > 0 ? totalBalance : 0.0;
    
    final isStudent = authProv.user?.role == 'student';

    return Column(
      children: [
        _buildMainBalanceCard(context, totalBalance).animate().fade(duration: 600.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMiniCard(context, 'Income', monthlyIncome, AppColors.success, Icons.arrow_downward).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1, end: 0)),
            const SizedBox(width: 16),
            Expanded(child: _buildMiniCard(context, 'Expense', monthlyExpense, AppColors.error, Icons.arrow_upward).animate().fade(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0)),
          ],
        ),
        const SizedBox(height: 16),
        if (isStudent)
          _buildSafeSpendCard(context, studentProv.calculateDailySafeSpend(monthlyIncome, monthlyExpense)).animate().fade(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0)
        else
          _buildSavingsCard(context, savings).animate().fade(duration: 600.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildMainBalanceCard(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, String title, double amount, Color color, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context, double amount) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.savings_outlined, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Savings', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSafeSpendCard(BuildContext context, double amount) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Safe Spend', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(2)} / day',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
