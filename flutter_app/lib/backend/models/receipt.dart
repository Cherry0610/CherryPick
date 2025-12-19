import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt {
  final String id;
  final String userId;
  final String storeId;
  final String storeName;
  final String imageUrl;
  final double totalAmount;
  final String currency;
  final DateTime purchaseDate;
  final List<ReceiptItem> items;
  final String status; // "pending", "processed", "failed"
  final String? ocrText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receipt({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.imageUrl,
    required this.totalAmount,
    required this.currency,
    required this.purchaseDate,
    required this.items,
    required this.status,
    this.ocrText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Receipt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Receipt(
      id: doc.id,
      userId: data['userId'] ?? '',
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MYR',
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItem.fromMap(item))
              .toList() ??
          [],
      status: data['status'] ?? 'pending',
      ocrText: data['ocrText'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'storeId': storeId,
      'storeName': storeName,
      'imageUrl': imageUrl,
      'totalAmount': totalAmount,
      'currency': currency,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'ocrText': ocrText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Receipt copyWith({
    String? id,
    String? userId,
    String? storeId,
    String? storeName,
    String? imageUrl,
    double? totalAmount,
    String? currency,
    DateTime? purchaseDate,
    List<ReceiptItem>? items,
    String? status,
    String? ocrText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      imageUrl: imageUrl ?? this.imageUrl,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      items: items ?? this.items,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ReceiptItem {
  final String productName;
  final double price;
  final int quantity;
  final String? productId; // If matched to existing product
  final String? category;

  ReceiptItem({
    required this.productName,
    required this.price,
    required this.quantity,
    this.productId,
    this.category,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      productId: map['productId'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'productId': productId,
      'category': category,
    };
  }
}


