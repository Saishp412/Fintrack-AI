import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../presentation/wallet_provider.dart';
import '../../../../core/providers/currency_provider.dart';

class WalletsDashboardScreen extends StatelessWidget {
  const WalletsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
      ),
      body: Consumer2<WalletProvider, CurrencyProvider>(
        builder: (context, provider, currencyProvider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final double totalNetWorth = provider.wallets.fold(0, (sum, item) => sum + item.balance);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Net Worth Card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Net Worth', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text(
                        '${currencyProvider.symbol}${totalNetWorth.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                
                // Wallets List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Linked Accounts', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: () => _showAddWalletModal(context),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 16),

                if (provider.wallets.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No wallets added yet.\nAdd your bank accounts, credit cards, or cash to start tracking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = provider.wallets[index];
                      IconData iconData = Icons.account_balance_wallet;
                      if (wallet.type == 'Bank') iconData = Icons.account_balance;
                      if (wallet.type == 'Credit Card') iconData = Icons.credit_card;
                      if (wallet.type == 'Cash') iconData = Icons.money;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(iconData, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(wallet.name, style: Theme.of(context).textTheme.titleLarge),
                                    Text(wallet.type, style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              Text(
                                '${currencyProvider.symbol}${wallet.balance.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(duration: 400.ms, delay: (200 + (100 * index)).ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddWalletModal(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'Bank';
    final types = ['Bank', 'Credit Card', 'Cash', 'Investment', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Link New Account', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Account Name (e.g. HDFC Bank)'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Account Type'),
                    items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Current Balance'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty && balanceController.text.isNotEmpty) {
                          final provider = Provider.of<WalletProvider>(context, listen: false);
                          await provider.addWallet(
                            nameController.text,
                            selectedType,
                            double.tryParse(balanceController.text) ?? 0.0,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('LINK ACCOUNT'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
