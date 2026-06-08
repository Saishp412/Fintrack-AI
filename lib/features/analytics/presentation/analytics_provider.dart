import 'package:flutter/material.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/transaction_provider.dart';

class AnalyticsProvider extends ChangeNotifier {
  final TransactionProvider transactionProvider;

  AnalyticsProvider({required this.transactionProvider}) {
    transactionProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    transactionProvider.removeListener(notifyListeners);
    super.dispose();
  }

  List<TransactionModel> get transactions => transactionProvider.transactions;

  // Pie Chart Data: Group expenses by category
  Map<String, double> get expensesByCategory {
    final Map<String, double> data = {};
    for (var tx in transactions.where((t) => !t.isIncome)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }
    return data;
  }

  // Get Highest Spending Category
  String get highestSpendingCategory {
    if (expensesByCategory.isEmpty) return 'None';
    return expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Calculate Savings Rate
  double get savingsRate {
    final double income = transactionProvider.totalIncome;
    final double expense = transactionProvider.totalExpense;
    if (income == 0) return 0.0;
    return ((income - expense) / income) * 100;
  }

  // Average Daily Spending for current month
  double get averageDailySpending {
    final now = DateTime.now();
    final currentMonthExpenses = transactions.where((t) => 
        !t.isIncome && t.date.month == now.month && t.date.year == now.year);
    
    final total = currentMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);
    return total / now.day; // divide by days passed in current month
  }
}
