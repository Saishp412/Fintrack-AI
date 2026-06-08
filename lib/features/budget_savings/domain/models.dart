class BudgetModel {
  final String category;
  final double limit;

  BudgetModel({required this.category, required this.limit});
}

class SavingsGoalModel {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String iconAsset; // Simplified for UI

  SavingsGoalModel({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.iconAsset = '',
  });

  double get progressPercentage => (currentAmount / targetAmount).clamp(0.0, 1.0);
}
