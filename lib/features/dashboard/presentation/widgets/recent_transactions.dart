import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../transactions/presentation/transaction_provider.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../../transactions/presentation/transaction_history_screen.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final allTx = provider.transactions;
    final recentTx = allTx.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                );
              },
              child: const Text('See All', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentTx.isEmpty)
          const Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textSecondary))),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTx.length,
          itemBuilder: (context, index) {
            final tx = recentTx[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionTile(context, tx),
            ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    final bool isIncome = tx.type == 'income';
    final Color amountColor = isIncome ? AppColors.success : AppColors.textPrimary;
    final String amountPrefix = isIncome ? '+' : '-';
    final dateStr = '${tx.date.day}/${tx.date.month}/${tx.date.year}';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix₹${tx.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
