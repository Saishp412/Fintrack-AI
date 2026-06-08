import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'student_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class SplitBillsScreen extends StatefulWidget {
  const SplitBillsScreen({super.key});

  @override
  State<SplitBillsScreen> createState() => _SplitBillsScreenState();
}

class _SplitBillsScreenState extends State<SplitBillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  bool _youOwe = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _personController.dispose();
    super.dispose();
  }

  void _addBill(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Split Bill', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'What for? (e.g. Canteen, Cab)'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _personController,
                decoration: const InputDecoration(labelText: 'Who is involved?'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) => SwitchListTile(
                  title: Text(_youOwe ? 'I owe them' : 'They owe me'),
                  value: _youOwe,
                  onChanged: (val) => setModalState(() => _youOwe = val),
                  activeColor: AppColors.error,
                  inactiveThumbColor: AppColors.success,
                  inactiveTrackColor: AppColors.success.withAlpha(80),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final provider = Provider.of<StudentProvider>(context, listen: false);
                    await provider.addSplitBill(
                      _titleController.text.trim(),
                      double.parse(_amountController.text.trim()),
                      _personController.text.trim(),
                      _youOwe,
                    );
                    _titleController.clear();
                    _amountController.clear();
                    _personController.clear();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add Bill', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final activeBills = provider.activeBills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bills'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBill(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoading && activeBills.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('You Owe', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('₹${provider.totalYouOwe.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.error, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('They Owe You', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('₹${provider.totalOwedToYou.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.success, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Active Splits', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20)),
                const SizedBox(height: 16),
                if (activeBills.isEmpty)
                  const Center(child: Text('No active split bills.', style: TextStyle(color: AppColors.textSecondary)))
                else
                  ...activeBills.map((bill) => Dismissible(
                    key: Key(bill.id),
                    background: Container(color: AppColors.success, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.check, color: Colors.white)),
                    secondaryBackground: Container(color: AppColors.error, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        provider.markAsSettled(bill.id, true);
                      } else {
                        provider.deleteBill(bill.id);
                      }
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(bill.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${bill.youOwe ? "You owe" : "Owes you"} ${bill.splitWith}\n${DateFormat.yMMMd().format(bill.createdAt)}', style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Text(
                          '₹${bill.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: bill.youOwe ? AppColors.error : AppColors.success,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),
              ],
            ),
    );
  }
}
