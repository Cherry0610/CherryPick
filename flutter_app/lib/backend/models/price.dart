import 'package:cloud_firestore/cloud_firestore.dart';

class Price {
  final String id;
  final String productId;
  final String storeId;
  final double price;
  final String currency; // RM
  final bool isOnSale;
  final double? originalPrice;
  final String? saleDescription;
  final DateTime validFrom;
  final DateTime? validUntil;
  final String? source; // 'scraped', 'receipt', 'manual'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Price({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.price,
    this.currency = 'RM',
    this.isOnSale = false,
    this.originalPrice,
    this.saleDescription,
    required this.validFrom,
    this.validUntil,
    this.source,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Price.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Price(
      id: doc.id,
      productId: data['productId'] ?? '',
      storeId: data['storeId'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'RM',
      isOnSale: data['isOnSale'] ?? false,
      originalPrice: data['originalPrice']?.toDouble(),
      saleDescription: data['saleDescription'],
      validFrom: (data['validFrom'] as Timestamp).toDate(),
      validUntil: data['validUntil'] != null
          ? (data['validUntil'] as Timestamp).toDate()
          : null,
      source: data['source'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'storeId': storeId,
      'price': price,
      'currency': currency,
      'isOnSale': isOnSale,
      'originalPrice': originalPrice,
      'saleDescription': saleDescription,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'source': source,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';

  String get formattedOriginalPrice => originalPrice != null
      ? '$currency ${originalPrice!.toStringAsFixed(2)}'
      : '';

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= 0) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  Price copyWith({
    String? id,
    String? productId,
    String? storeId,
    double? price,
    String? currency,
    bool? isOnSale,
    double? originalPrice,
    String? saleDescription,
    DateTime? validFrom,
    DateTime? validUntil,
    String? source,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Price(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isOnSale: isOnSale ?? this.isOnSale,
      originalPrice: originalPrice ?? this.originalPrice,
      saleDescription: saleDescription ?? this.saleDescription,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

