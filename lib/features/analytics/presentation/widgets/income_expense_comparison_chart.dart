import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:math';

class IncomeExpenseComparisonChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseComparisonChart({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    if (income == 0 && expense == 0) {
      return const SizedBox.shrink();
    }

    final double maxY = max(income, expense) * 1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash Flow Comparison', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY == 0 ? 1000 : maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14);
                        return SideTitleWidget(
                          meta: meta,
                          space: 16,
                          child: Text(value == 0 ? 'Income' : 'Expense', style: style),
                        );
                      },
                      reservedSize: 38,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: AppColors.success,
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expense,
                        color: AppColors.error,
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
