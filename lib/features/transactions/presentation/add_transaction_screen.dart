import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'transaction_provider.dart';
import '../../trips/domain/trip_model.dart';
import '../../trips/presentation/trip_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../ai_insights/data/ai_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;
  
  const AddTransactionScreen({super.key, this.isIncome = false});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  late bool _isIncome;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTripId;
  final _splitWithController = TextEditingController();
  
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();

  List<String> get _incomeCategories {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    if (authProv.user?.role == 'student') {
      return ['Pocket Money', 'Part-time Salary', 'Freelancing', 'Side Hustle', 'Investments', 'Other'];
    }
    return ['Salary', 'Freelancing', 'Investments', 'Other'];
  }

  List<String> get _expenseCategories {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    if (authProv.user?.role == 'student') {
      return ['Food/Canteen', 'Travel/Cab', 'Education/Stationery', 'Shopping', 'Entertainment', 'Bills/Rent', 'Healthcare', 'Other'];
    }
    return ['Food', 'Travel', 'Shopping', 'Entertainment', 'Education', 'Bills', 'Healthcare', 'Other'];
  }

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isIncome;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _splitWithController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final success = await provider.addTransaction(
        double.parse(_amountController.text),
        _selectedCategory!,
        _isIncome ? 'income' : 'expense',
        _selectedDate,
        _notesController.text.trim(),
        tripId: _selectedTripId,
        splitWith: _splitWithController.text.trim().isEmpty ? null : _splitWithController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to save'), backgroundColor: AppColors.error),
        );
      }
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _scanReceipt(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
      if (image == null) return;

      setState(() => _isScanning = true);

      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final role = authProv.user?.role ?? 'professional';

      final result = await _aiService.scanReceipt(base64Image, role, _isIncome ? _incomeCategories : _expenseCategories);

      if (result != null && mounted) {
        setState(() {
          if (result['amount'] != null) {
            _amountController.text = result['amount'].toString();
          }
          if (result['category'] != null && (_isIncome ? _incomeCategories : _expenseCategories).contains(result['category'])) {
            _selectedCategory = result['category'];
          }
          if (result['notes'] != null) {
            _notesController.text = result['notes'];
          }
          if (result['date'] != null) {
            try {
              _selectedDate = DateTime.parse(result['date']);
            } catch (_) {} // Ignore invalid dates
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt Scanned Successfully!'), backgroundColor: AppColors.success),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read receipt.'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = _isIncome ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isIncome ? 'Add Income' : 'Add Expense'),
        backgroundColor: _isIncome ? AppColors.success.withAlpha(50) : AppColors.error.withAlpha(50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Switcher
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: (val) {
                        setState(() {
                          _isIncome = false;
                          _selectedCategory = null;
                        });
                      },
                      selectedColor: AppColors.error.withAlpha(80),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: _isIncome,
                      onSelected: (val) {
                        setState(() {
                          _isIncome = true;
                          _selectedCategory = null;
                        });
                      },
                      selectedColor: AppColors.success.withAlpha(80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Scan Receipt Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isScanning
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.surface,
                            builder: (ctx) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                                    title: const Text('Take Photo'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _scanReceipt(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library, color: AppColors.primary),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _scanReceipt(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  icon: _isScanning 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.document_scanner),
                  label: Text(
                    _isScanning ? 'Analyzing Receipt...' : 'Scan Receipt',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withAlpha(50),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'This feature is currently unavailable due to beta testing.',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  labelText: 'Amount',
                ),
                validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == null) ? 'Enter valid amount' : null,
              ),
              const SizedBox(height: 24),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 24),
              
              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(DateFormat.yMMMd().format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Trip Selection
              Consumer<TripProvider>(
                builder: (context, tripProv, child) {
                  if (tripProv.trips.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedTripId,
                        hint: const Text('Link to Trip (Optional)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...tripProv.trips.map((trip) => DropdownMenuItem(value: trip.id, child: Text(trip.name))),
                        ],
                        onChanged: (val) => setState(() => _selectedTripId = val),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _splitWithController,
                        decoration: const InputDecoration(labelText: 'Split With (Optional)'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              CustomButton(
                text: 'Save Transaction',
                isLoading: provider.isLoading,
                onPressed: _saveTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
