import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/main/presentation/main_screen.dart';
import 'features/transactions/presentation/transaction_provider.dart';
import 'features/analytics/presentation/analytics_provider.dart';
import 'features/subscriptions/presentation/subscription_provider.dart';
import 'features/trips/presentation/trip_provider.dart';
import 'features/budget_savings/presentation/goal_provider.dart';
import 'features/profile/presentation/wallet_provider.dart';
import 'features/student/presentation/student_provider.dart';
import 'core/providers/currency_provider.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
  }

  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TripProvider>(
          create: (_) => TripProvider(userId: ''),
          update: (_, auth, previous) {
            final newUserId = auth.user?.uid ?? '';
            if (previous != null && previous.userId == newUserId) return previous;
            return TripProvider(userId: newUserId);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (_) => GoalProvider(userId: ''),
          update: (_, auth, previous) {
            final newUserId = auth.user?.uid ?? '';
            if (previous != null && previous.userId == newUserId) return previous;
            return GoalProvider(userId: newUserId);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (_) => WalletProvider(userId: ''),
          update: (_, auth, previous) {
            final newUserId = auth.user?.uid ?? '';
            if (previous != null && previous.userId == newUserId) return previous;
            return WalletProvider(userId: newUserId);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(userId: ''),
          update: (_, auth, previous) {
            final newUserId = auth.user?.uid ?? '';
            if (previous != null && previous.userId == newUserId) return previous;
            return TransactionProvider(userId: newUserId);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, StudentProvider>(
          create: (_) => StudentProvider(userId: ''),
          update: (_, auth, previous) {
            final newUserId = auth.user?.uid ?? '';
            if (previous != null && previous.userId == newUserId) return previous;
            return StudentProvider(userId: newUserId);
          },
        ),
        ChangeNotifierProxyProvider<TransactionProvider, AnalyticsProvider>(
          create: (ctx) => AnalyticsProvider(transactionProvider: Provider.of<TransactionProvider>(ctx, listen: false)),
          update: (_, txProv, previous) => AnalyticsProvider(transactionProvider: txProv),
        ),
      ],
      child: MaterialApp(
        title: 'FinTrack AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500), // Enforce mobile width on web/tablets
              decoration: const BoxDecoration(
                gradient: AppColors.cosmicGradient,
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: MediaQuery(
                // Clamp text scale factor to prevent OS level huge fonts from breaking UI
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              ),
            ),
          );
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
