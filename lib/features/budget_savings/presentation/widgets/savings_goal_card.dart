import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/goal_model.dart';

class SavingsGoalCard extends StatelessWidget {
  final GoalModel goal;

  const SavingsGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final percentage = goal.targetAmount > 0 
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) 
        : 0.0;
        
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '₹${goal.savedAmount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'of ₹${goal.targetAmount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
