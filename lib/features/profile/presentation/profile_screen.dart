import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../subscriptions/presentation/subscriptions_screen.dart';
import '../../trips/presentation/trips_dashboard_screen.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'currency_manager_screen.dart';
import 'wallets_dashboard_screen.dart';
import '../../budget_savings/presentation/goals_dashboard_screen.dart';
import '../../transactions/presentation/transaction_provider.dart';
import '../../analytics/data/export_service.dart';
import '../../../../core/widgets/custom_button.dart';
import 'notifications_settings_screen.dart';
import 'security_settings_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withAlpha(50),
              backgroundImage: user?.profileImageUrl.isNotEmpty == true 
                  ? NetworkImage(user!.profileImageUrl) 
                  : null,
              child: user?.profileImageUrl.isEmpty == true 
                  ? const Icon(Icons.person, size: 50, color: AppColors.primary) 
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Name & Email
            Text(
              user?.fullName ?? 'User Name',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'email@example.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 40),
            
            // Settings List
            _buildSettingsItem(
              context, 
              Icons.notifications_outlined, 
              'Notifications', 
              'On',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.security_outlined, 
              'Security', 
              'Password, Biometrics',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen())),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.help_outline, 
              'Help & Support', 
              'FAQ, Contact Us',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.info_outline, 
              'About FinTrack', 
              'Version 1.0.0',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            
            const SizedBox(height: 48),
            
            // Advanced Features
            _buildSettingsItem(
              context, 
              Icons.account_balance_wallet, 
              'Linked Wallets', 
              'Manage your bank and card accounts',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletsDashboardScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.track_changes, 
              'Financial Goals', 
              'Set goals and track savings',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsDashboardScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.currency_exchange, 
              'Currency Settings', 
              'Change app currency symbol',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyManagerScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.flight_takeoff, 
              'Trip Tracker', 
              'Manage your vacations and budgets',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TripsDashboardScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.autorenew, 
              'Recurring Subscriptions', 
              'Manage your monthly bills',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context, 
              Icons.table_chart_outlined, 
              'Export Raw Data (CSV)', 
              'Download full ledger for Excel',
              onTap: () {
                final txProvider = Provider.of<TransactionProvider>(context, listen: false);
                ExportService.generateAndDownloadCsv(txProvider.transactions, 'fintrack_full_ledger');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV Exported Successfully!')),
                );
              },
            ),
            const SizedBox(height: 16),
            
            _buildSettingsItem(
              context, 
              Icons.delete_sweep_outlined, 
              'Clear Transaction Logs', 
              'Delete today\'s or all-time data',
              onTap: () {
                _showClearLogsDialog(context);
              },
            ),
            const SizedBox(height: 16),
            
            // Logout Button
            CustomButton(
              text: 'Log Out',
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      ),
    );
  }

  void _showClearLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Transaction Logs', style: TextStyle(color: AppColors.error)),
        content: const Text('Do you want to clear only today\'s transactions, or all-time data? This action cannot be undone.', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final txProvider = Provider.of<TransactionProvider>(context, listen: false);
              await txProvider.clearTransactions(todayOnly: true);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Today\'s logs cleared.')));
              }
            },
            child: const Text('Clear Today', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              final txProvider = Provider.of<TransactionProvider>(context, listen: false);
              await txProvider.clearTransactions(todayOnly: false);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('All-time logs cleared.')));
              }
            },
            child: const Text('Clear All Time', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
