import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../analytics_provider.dart';
import '../../../../core/constants/app_colors.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        // Simplified for Phase 4: Show current month Income vs Expense
        final double income = provider.transactionProvider.totalIncome;
        final double expense = provider.transactionProvider.totalExpense;

        return SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (income > expense ? income : expense) * 1.2, // Add 20% headroom
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14);
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('Income', style: style);
                          break;
                        case 1:
                          text = const Text('Expense', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(meta: meta, space: 16, child: text);
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppColors.success,
                      width: 40,
                      borderRadius: BorderRadius.circular(8),
                    )
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
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
