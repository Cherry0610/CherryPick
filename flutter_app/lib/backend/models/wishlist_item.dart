import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double targetPrice;
  final String currency;
  final bool isActive;
  final List<String> preferredStores; // Store IDs
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastNotifiedAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.targetPrice,
    required this.currency,
    required this.isActive,
    required this.preferredStores,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.lastNotifiedAt,
  });

  factory WishlistItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WishlistItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'],
      targetPrice: (data['targetPrice'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MYR',
      isActive: data['isActive'] ?? true,
      preferredStores: List<String>.from(data['preferredStores'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastNotifiedAt: data['lastNotifiedAt'] != null
          ? (data['lastNotifiedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'targetPrice': targetPrice,
      'currency': currency,
      'isActive': isActive,
      'preferredStores': preferredStores,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastNotifiedAt': lastNotifiedAt != null
          ? Timestamp.fromDate(lastNotifiedAt!)
          : null,
    };
  }

  String get formattedTargetPrice =>
      '$currency ${targetPrice.toStringAsFixed(2)}';

  WishlistItem copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImageUrl,
    double? targetPrice,
    String? currency,
    bool? isActive,
    List<String>? preferredStores,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastNotifiedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      targetPrice: targetPrice ?? this.targetPrice,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      preferredStores: preferredStores ?? this.preferredStores,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
    );
  }
}
