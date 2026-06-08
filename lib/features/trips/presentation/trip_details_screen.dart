import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../domain/trip_model.dart';
import '../../transactions/presentation/transaction_provider.dart';
import '../../analytics/data/pdf_service.dart';
import '../../analytics/presentation/widgets/category_breakdown_chart.dart';

class TripDetailsScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            onPressed: () async {
              final txProvider = Provider.of<TransactionProvider>(context, listen: false);
              final tripTransactions = txProvider.transactions.where((t) => t.tripId == trip.id).toList();
              final tripExpense = tripTransactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
              final tripIncome = tripTransactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

              await PdfService.generateAndPrintMonthlyReport(
                income: tripIncome,
                expense: tripExpense,
                transactions: tripTransactions,
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          final tripTransactions = txProvider.transactions.where((t) => t.tripId == trip.id).toList();
          final tripExpense = tripTransactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

          final Map<String, double> tripCategoryTotals = {};
          for (var tx in tripTransactions.where((t) => !t.isIncome)) {
            tripCategoryTotals[tx.category] = (tripCategoryTotals[tx.category] ?? 0) + tx.amount;
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Total Spent on Trip', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '₹${tripExpense.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: [
                          Tab(text: 'Transactions'),
                          Tab(text: 'Analytics'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Transactions Tab
                            ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: tripTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = tripTransactions[index];
                                return ListTile(
                                  title: Text(tx.category),
                                  subtitle: Text(tx.notes.isNotEmpty ? tx.notes : tx.date.toString().substring(0, 10)),
                                  trailing: Text(
                                    '₹${tx.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: tx.isIncome ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            // Analytics Tab
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CategoryBreakdownChart(categoryTotals: tripCategoryTotals),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
