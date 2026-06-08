import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/budget_card.dart';
import 'widgets/savings_goal_card.dart';
import '../domain/models.dart';
import '../../analytics/presentation/analytics_provider.dart';
import '../presentation/goal_provider.dart';

class BudgetSavingsScreen extends StatelessWidget {
  const BudgetSavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded targets for showcase purposes
    final List<BudgetModel> budgets = [
      BudgetModel(category: 'Food', limit: 10000),
      BudgetModel(category: 'Shopping', limit: 5000),
      BudgetModel(category: 'Entertainment', limit: 3000),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Goals'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analytics, child) {
          final expenses = analytics.expensesByCategory;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Savings Goals Section (Horizontal Scroll)
                Text('Savings Goals', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Consumer<GoalProvider>(
                    builder: (context, goalProv, child) {
                      if (goalProv.goals.isEmpty) {
                        return const Center(child: Text('No savings goals yet.'));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: goalProv.goals.length,
                        itemBuilder: (context, index) {
                          return SavingsGoalCard(goal: goalProv.goals[index]);
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 40),

                // Budgets Section (Vertical List)
                Text('Monthly Budgets', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budgets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final currentSpent = expenses[budget.category] ?? 0.0;
                    return BudgetCard(budget: budget, currentSpent: currentSpent);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
