import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.password, color: AppColors.primary),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
            },
          ),
          const Divider(color: AppColors.surface),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use Face ID / Touch ID to open app'),
            activeColor: AppColors.primary,
            value: _biometricsEnabled,
            onChanged: (val) => setState(() => _biometricsEnabled = val),
          ),
          const Divider(color: AppColors.surface),
          ListTile(
            leading: const Icon(Icons.devices, color: AppColors.primary),
            title: const Text('Active Devices'),
            subtitle: const Text('Manage devices logged into your account'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {
              // Future implementation
            },
          ),
        ],
      ),
    );
  }
}
