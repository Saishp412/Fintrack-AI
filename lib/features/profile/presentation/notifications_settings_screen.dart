import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _budgetAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts on your device'),
            activeColor: AppColors.primary,
            value: _pushEnabled,
            onChanged: (val) => setState(() => _pushEnabled = val),
          ),
          const Divider(color: AppColors.surface),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive weekly reports via email'),
            activeColor: AppColors.primary,
            value: _emailEnabled,
            onChanged: (val) => setState(() => _emailEnabled = val),
          ),
          const Divider(color: AppColors.surface),
          SwitchListTile(
            title: const Text('Budget Alerts'),
            subtitle: const Text('Get notified when nearing your budget limit'),
            activeColor: AppColors.primary,
            value: _budgetAlerts,
            onChanged: (val) => setState(() => _budgetAlerts = val),
          ),
        ],
      ),
    );
  }
}
