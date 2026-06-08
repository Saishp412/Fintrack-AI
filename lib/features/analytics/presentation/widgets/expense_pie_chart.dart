import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../analytics_provider.dart';
import '../../../../core/constants/app_colors.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final data = provider.expensesByCategory;
        
        if (data.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No expenses recorded yet.')),
          );
        }

        final colors = [
          AppColors.primary,
          AppColors.secondary,
          AppColors.error,
          AppColors.warning,
          Colors.purpleAccent,
          Colors.cyan,
          Colors.teal,
          Colors.orangeAccent,
        ];

        int colorIndex = 0;
        final List<PieChartSectionData> sections = data.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${(entry.value / provider.transactionProvider.totalExpense * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: _Badge(entry.key, color),
            badgePositionPercentageOffset: 1.2,
          );
        }).toList();

        return SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: sections,
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }
}
