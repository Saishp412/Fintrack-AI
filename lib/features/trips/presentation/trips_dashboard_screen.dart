import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../domain/trip_model.dart';
import '../presentation/trip_provider.dart';
import '../../transactions/presentation/transaction_provider.dart';
import 'trip_details_screen.dart';

class TripsDashboardScreen extends StatefulWidget {
  const TripsDashboardScreen({super.key});

  @override
  State<TripsDashboardScreen> createState() => _TripsDashboardScreenState();
}

class _TripsDashboardScreenState extends State<TripsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Tracker'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer2<TripProvider, TransactionProvider>(
        builder: (context, tripProvider, txProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripProvider.trips.isEmpty) {
            return const Center(
              child: Text(
                'No trips planned yet.\nTap + to create a new trip!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tripProvider.trips.length,
            itemBuilder: (context, index) {
              final trip = tripProvider.trips[index];
              // Calculate total spent on this trip
              final tripExpenses = txProvider.transactions
                  .where((tx) => tx.tripId == trip.id && !tx.isIncome)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              
              final double percentage = trip.budget > 0 ? (tripExpenses / trip.budget).clamp(0.0, 1.0) : 0.0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailsScreen(trip: trip),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.secondary.withAlpha(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(trip.name, style: Theme.of(context).textTheme.titleLarge),
                          const Icon(Icons.flight_takeoff, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Spent: ₹${tripExpenses.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Budget: ₹${trip.budget.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.background,
                        color: percentage > 0.9 ? AppColors.error : AppColors.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTripModal(context),
      ),
    );
  }

  void _showAddTripModal(BuildContext context) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan New Trip', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Trip Name (e.g. Goa 2026)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Total Budget (₹)'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                      final provider = Provider.of<TripProvider>(context, listen: false);
                      await provider.addTrip(
                        nameController.text,
                        double.tryParse(budgetController.text) ?? 0.0,
                        startDate,
                        endDate,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('CREATE TRIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
