import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/summary_cards.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.fullName.split(' ').first ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Temporary logout button until Profile module is ready
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                      backgroundImage: authProvider.user?.profileImageUrl.isNotEmpty == true 
                          ? NetworkImage(authProvider.user!.profileImageUrl) 
                          : null,
                      child: authProvider.user?.profileImageUrl.isEmpty == true 
                          ? const Icon(Icons.person) 
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Summary Cards
              const SummaryCards(),
              const SizedBox(height: 32),
              
              // Quick Actions
              const QuickActions(),
              const SizedBox(height: 32),
              
              // Recent Transactions List
              const RecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }
}
