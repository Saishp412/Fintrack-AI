import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../presentation/goal_provider.dart';
import '../domain/goal_model.dart';
import '../../../../core/providers/currency_provider.dart';

class GoalsDashboardScreen extends StatelessWidget {
  const GoalsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
      ),
      body: Consumer2<GoalProvider, CurrencyProvider>(
        builder: (context, provider, currencyProvider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.goals.isEmpty) {
            return const Center(
              child: Text(
                'No goals set yet.\nTap + to dream big!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              final percentage = goal.targetAmount > 0 
                  ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) 
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppColors.primary),
                            onPressed: () => _showAddFundsModal(context, goal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saved: ${currencyProvider.symbol}${goal.savedAmount.toStringAsFixed(0)}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          Text(
                            'Target: ${currencyProvider.symbol}${goal.targetAmount.toStringAsFixed(0)}', 
                            style: const TextStyle(color: AppColors.textSecondary)
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.background,
                        color: percentage >= 1.0 ? AppColors.success : AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms, delay: (100 * index).ms).slideY(begin: 0.1, end: 0),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddGoalModal(context),
      ),
    );
  }

  void _showAddGoalModal(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 90));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Goal', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Goal Name (e.g. MacBook)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Amount'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && targetController.text.isNotEmpty) {
                      final provider = Provider.of<GoalProvider>(context, listen: false);
                      await provider.addGoal(
                        nameController.text,
                        double.tryParse(targetController.text) ?? 0.0,
                        targetDate,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('CREATE GOAL'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddFundsModal(BuildContext context, GoalModel goal) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Funds to ${goal.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount to Add'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (amountController.text.isNotEmpty) {
                      final provider = Provider.of<GoalProvider>(context, listen: false);
                      await provider.addFundsToGoal(
                        goal.id,
                        double.tryParse(amountController.text) ?? 0.0,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('ADD FUNDS'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
