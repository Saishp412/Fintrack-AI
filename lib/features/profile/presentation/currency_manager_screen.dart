import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/currency_provider.dart';

class CurrencyManagerScreen extends StatelessWidget {
  const CurrencyManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencies = [
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Settings'),
      ),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = provider.code == currency['code'];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    provider.setCurrency(currency['symbol']!, currency['code']!);
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    showBorder: isSelected,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currency['symbol']!,
                            style: TextStyle(
                              fontSize: 24,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currency['name']!, style: Theme.of(context).textTheme.titleLarge),
                              Text(currency['code']!, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
