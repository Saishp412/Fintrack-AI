import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Us', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.email, color: AppColors.primary),
              title: Text('Email Support'),
              subtitle: Text('saishpatil41204@gmail.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: AppColors.primary),
              title: Text('Phone Support'),
              subtitle: Text('+91 9136068562'),
            ),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions (FAQ)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const ExpansionTile(
              title: Text('How do I reset my account data?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Go to Profile -> Clear Transaction Logs to reset your data.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('Is the AI advice free?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Yes, the FinTrack Generative AI is included in your standard plan.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('How do Split Bills work?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Students can use the Split Bills quick action to track who owes them money or who they owe money to.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
