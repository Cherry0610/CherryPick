import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseTracking {
  final String id;
  final String userId;
  final String category; // groceries, household, personal, etc.
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final String? receiptId;
  final String? storeId;
  final String? storeName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseTracking({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.currency = 'RM',
    required this.description,
    required this.date,
    this.receiptId,
    this.storeId,
    this.storeName,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseTracking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExpenseTracking(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'RM',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      receiptId: data['receiptId'],
      storeId: data['storeId'],
      storeName: data['storeName'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': Timestamp.fromDate(date),
      'receiptId': receiptId,
      'storeId': storeId,
      'storeName': storeName,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  ExpenseTracking copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    String? receiptId,
    String? storeId,
    String? storeName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptId: receiptId ?? this.receiptId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isActive;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isActive = true,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'shopping_cart',
      color: map['color'] ?? '#2196F3',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isActive': isActive,
    };
  }
}

class MonthlyExpenseSummary {
  final String month;
  final double totalAmount;
  final String currency;
  final Map<String, double> categoryBreakdown;
  final int transactionCount;
  final double averageTransaction;
  final double previousMonthAmount;
  final double percentageChange;

  MonthlyExpenseSummary({
    required this.month,
    required this.totalAmount,
    this.currency = 'RM',
    required this.categoryBreakdown,
    required this.transactionCount,
    required this.averageTransaction,
    required this.previousMonthAmount,
    required this.percentageChange,
  });

  String get formattedTotalAmount =>
      '$currency ${totalAmount.toStringAsFixed(2)}';
  String get formattedAverageTransaction =>
      '$currency ${averageTransaction.toStringAsFixed(2)}';
  String get formattedPreviousMonthAmount =>
      '$currency ${previousMonthAmount.toStringAsFixed(2)}';
  String get formattedPercentageChange =>
      '${percentageChange.toStringAsFixed(1)}%';
}
