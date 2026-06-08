import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final double currentSpent;

  const BudgetCard({super.key, required this.budget, required this.currentSpent});

  @override
  Widget build(BuildContext context) {
    final double progress = (currentSpent / budget.limit).clamp(0.0, 1.0);
    final bool isWarning = progress > 0.8;
    final bool isExceeded = progress >= 1.0;

    Color progressColor = AppColors.success;
    if (isExceeded) progressColor = AppColors.error;
    else if (isWarning) progressColor = AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(budget.category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
              Text(
                '₹${currentSpent.toStringAsFixed(0)} / ₹${budget.limit.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (isWarning || isExceeded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                isExceeded ? 'Budget Exceeded!' : 'Nearing Budget Limit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isExceeded ? AppColors.error : AppColors.warning,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
