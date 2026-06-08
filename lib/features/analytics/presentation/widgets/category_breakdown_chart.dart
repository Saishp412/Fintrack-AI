import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:math';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryBreakdownChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending

    final topEntries = sortedEntries.take(5).toList(); // Top 5 categories
    final double maxAmount = topEntries.isNotEmpty ? topEntries.first.value : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Expense Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...topEntries.map((e) => _buildBar(context, e.key, e.value, maxAmount)),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String category, double amount, double maxAmount) {
    final double percentage = maxAmount > 0 ? (amount / maxAmount) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 12,
                    width: constraints.maxWidth * percentage,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
