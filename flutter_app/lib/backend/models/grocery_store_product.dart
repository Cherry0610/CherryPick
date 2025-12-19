/// Model for products from grocery store APIs
class GroceryStoreProduct {
  final String id;
  final String name;
  final String storeName; // e.g., "Shopee", "Lazada", "GrabMart"
  final double price;
  final String? originalPrice; // For showing discounts
  final String currency;
  final String imageUrl;
  final String productUrl; // Link to the product page
  final String? brand;
  final String? category;
  final String? unit; // e.g., "500g", "1kg", "1 piece"
  final bool inStock;
  final double? rating;
  final int? reviewCount;
  final String? description;
  final Map<String, dynamic>? metadata; // Additional store-specific data

  GroceryStoreProduct({
    required this.id,
    required this.name,
    required this.storeName,
    required this.price,
    this.originalPrice,
    this.currency = 'MYR',
    required this.imageUrl,
    required this.productUrl,
    this.brand,
    this.category,
    this.unit,
    this.inStock = true,
    this.rating,
    this.reviewCount,
    this.description,
    this.metadata,
  });

  factory GroceryStoreProduct.fromJson(Map<String, dynamic> json) {
    return GroceryStoreProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      storeName: json['storeName'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] as String?,
      currency: json['currency'] as String? ?? 'MYR',
      imageUrl: json['imageUrl'] as String,
      productUrl: json['productUrl'] as String,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      inStock: json['inStock'] as bool? ?? true,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'storeName': storeName,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
      'brand': brand,
      'category': category,
      'unit': unit,
      'inStock': inStock,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'metadata': metadata,
    };
  }

  /// Calculate discount percentage if original price exists
  double? get discountPercentage {
    if (originalPrice == null) return null;
    try {
      final original = double.parse(originalPrice!.replaceAll(RegExp(r'[^\d.]'), ''));
      if (original > price) {
        return ((original - price) / original) * 100;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}





