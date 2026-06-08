class SubscriptionModel {
  final String id;
  final String name;
  final double amount;
  final int billingDay;
  final String category;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingDay,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billingDay': billingDay,
      'category': category,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionModel(
      id: id,
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      billingDay: map['billingDay'] ?? 1,
      category: map['category'] ?? 'Subscriptions',
    );
  }
}
