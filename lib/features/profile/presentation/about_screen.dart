import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About FinTrack')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.account_balance_wallet, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('FinTrack AI', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            const Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            Text(
              'FinTrack is a revolutionary personal finance assistant powered by Artificial Intelligence. '
              'It features a dual-architecture system customized for both Students and Working Professionals.\n\n'
              'Whether you are managing pocket money and splitting canteen bills, or tracking '
              'stock investments and analyzing long-term wealth, FinTrack gives you actionable insights '
              'to make smarter financial decisions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 48),
            const Text('Developed by the FinTrack Team', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('© 2026 All Rights Reserved', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
