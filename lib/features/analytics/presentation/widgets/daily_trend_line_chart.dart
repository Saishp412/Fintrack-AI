import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../transactions/domain/transaction_model.dart';
import 'dart:math';

class DailyTrendLineChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const DailyTrendLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No data for trend', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    // Group expenses by day for the last 15 days or current month
    final Map<int, double> dailyExpenses = {};
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      dailyExpenses[now.subtract(Duration(days: i)).day] = 0;
    }

    for (var tx in transactions) {
      if (!tx.isIncome && now.difference(tx.date).inDays < 14) {
        dailyExpenses[tx.date.day] = (dailyExpenses[tx.date.day] ?? 0) + tx.amount;
      }
    }

    final sortedDays = dailyExpenses.keys.toList()..sort();
    final spots = sortedDays.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), dailyExpenses[e.value]!);
    }).toList();

    double maxY = dailyExpenses.values.fold(0, max);
    if (maxY == 0) maxY = 1000; // default scale

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
          Text('14-Day Spending Trend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedDays.length) {
                          // Show day every other label to prevent crowding
                          if (value.toInt() % 3 == 0) {
                            return SideTitleWidget(meta: meta, child: Text(sortedDays[value.toInt()].toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)));
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return SideTitleWidget(meta: meta, child: Text('₹${(value / 1000).toStringAsFixed(1)}k', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sortedDays.length - 1).toDouble(),
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.secondary.withAlpha(30),
                    ),
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
