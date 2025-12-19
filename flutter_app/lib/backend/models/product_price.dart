import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPrice {
  final String id;
  final String productId;
  final String storeId;
  final double price;
  final String currency; // "MYR"
  final bool isOnSale;
  final double? originalPrice;
  final String? saleDescription;
  final DateTime priceDate;
  final String source; // "website", "receipt", "manual"
  final String? receiptId; // If price came from receipt upload
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductPrice({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.price,
    required this.currency,
    required this.isOnSale,
    this.originalPrice,
    this.saleDescription,
    required this.priceDate,
    required this.source,
    this.receiptId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductPrice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductPrice(
      id: doc.id,
      productId: data['productId'] ?? '',
      storeId: data['storeId'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MYR',
      isOnSale: data['isOnSale'] ?? false,
      originalPrice: data['originalPrice']?.toDouble(),
      saleDescription: data['saleDescription'],
      priceDate: (data['priceDate'] as Timestamp).toDate(),
      source: data['source'] ?? 'manual',
      receiptId: data['receiptId'],
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
      'priceDate': Timestamp.fromDate(priceDate),
      'source': source,
      'receiptId': receiptId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}


