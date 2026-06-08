import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'subscription_provider.dart';
import '../domain/subscription_model.dart';
import '../../transactions/presentation/transaction_provider.dart';
import '../../transactions/domain/transaction_model.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Subscriptions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubscriptionModal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.subscriptions.isEmpty) {
            return const Center(
              child: Text('No subscriptions added yet.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subscriptions.length,
            itemBuilder: (context, index) {
              final sub = provider.subscriptions[index];
              return _buildSubscriptionCard(context, sub);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, SubscriptionModel sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withAlpha(20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(30),
            child: const Icon(Icons.autorenew, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text('Bills on day ${sub.billingDay} of month', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${sub.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Auto-pay feature
                  Provider.of<TransactionProvider>(context, listen: false).addTransaction(
                    sub.amount,
                    sub.category,
                    'expense',
                    DateTime.now(),
                    'Auto-paid ${sub.name}',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked ${sub.name} as Paid!')));
                },
                child: const Text('MARK PAID', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSubscriptionModal(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
              const Text('Add Subscription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name (e.g. Netflix)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Billing Day (1-31)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final sub = SubscriptionModel(
                      id: '',
                      name: nameController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      billingDay: int.tryParse(dayController.text) ?? 1,
                      category: 'Subscriptions',
                    );
                    Provider.of<SubscriptionProvider>(context, listen: false).addSubscription(sub);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Subscription'),
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
