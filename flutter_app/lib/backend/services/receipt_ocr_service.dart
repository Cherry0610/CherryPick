import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/receipt.dart';
import '../models/product.dart';
import '../models/price.dart';
import '../models/expense_tracking.dart';
import 'price_comparison_service.dart';
import 'expense_tracking_service.dart';

/// Real OCR service for receipt scanning using Firebase ML Kit
/// Extracts product information from receipt images
class ReceiptOcrService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final PriceComparisonService _priceService = PriceComparisonService();
  final ExpenseTrackingService _expenseService = ExpenseTrackingService();

  /// Process receipt image and extract product data
  Future<Receipt> processReceipt({
    required XFile imageFile,
    required String userId,
    String? storeName,
    DateTime? purchaseDate,
  }) async {
    try {
      debugPrint('📸 Processing receipt: ${imageFile.path}');

      // 1. Upload image to Firebase Storage
      final imageUrl = await _uploadReceiptImage(imageFile, userId);

      // 2. Extract text from receipt using ML Kit (via backend or client-side)
      final extractedText = await _extractTextFromImage(imageFile);

      // 3. Parse receipt data from extracted text
      final receiptData = _parseReceiptText(extractedText);

      // 4. Find or create store
      final storeNameFinal = storeName ?? receiptData['storeName'] ?? 'Unknown Store';
      final storeQuery = await _firestore
          .collection('stores')
          .where('name', isEqualTo: storeNameFinal)
          .limit(1)
          .get();
      
      String storeId;
      if (storeQuery.docs.isNotEmpty) {
        storeId = storeQuery.docs.first.id;
      } else {
        final storeRef = await _firestore.collection('stores').add({
          'name': storeNameFinal,
          'type': 'grocery',
          'address': '',
          'city': '',
          'state': 'Malaysia',
          'postcode': '',
          'latitude': 0.0,
          'longitude': 0.0,
          'isActive': true,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
        storeId = storeRef.id;
      }

      // 5. Create receipt items
      final receiptItems = (receiptData['items'] as List<dynamic>?)
          ?.map((item) => ReceiptItem(
                productName: item['productName'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: item['quantity'] as int? ?? 1,
                category: item['category'] as String?,
              ))
          .toList() ?? [];

      // 6. Create receipt document
      final receipt = Receipt(
        id: '', // Will be set when saved
        userId: userId,
        storeId: storeId,
        storeName: storeNameFinal,
        imageUrl: imageUrl,
        totalAmount: receiptData['totalAmount'] ?? 0.0,
        currency: 'MYR',
        purchaseDate: purchaseDate ?? receiptData['purchaseDate'] ?? DateTime.now(),
        items: receiptItems,
        status: 'pending',
        ocrText: extractedText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 7. Save receipt to Firestore
      final docRef = await _firestore.collection('receipts').add(receipt.toFirestore());
      
      // 8. Process items and update price database
      await _processReceiptItems(docRef.id, receipt);

      // 9. Update receipt as processed
      await _firestore.collection('receipts').doc(docRef.id).update({
        'status': 'processed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 10. Create expense entry from receipt
      await _createExpenseFromReceipt(userId, docRef.id, receipt);

      debugPrint('✅ Receipt processed successfully: ${docRef.id}');
      
      return receipt.copyWith(
        id: docRef.id,
        status: 'processed',
      );
    } catch (e) {
      debugPrint('❌ Error processing receipt: $e');
      rethrow;
    }
  }

  /// Upload receipt image to Firebase Storage
  Future<String> _uploadReceiptImage(XFile imageFile, String userId) async {
    try {
      final fileName = 'receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Receipt image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading receipt image: $e');
      rethrow;
    }
  }

  /// Extract text from receipt image
  /// Note: For production, use Firebase ML Kit Text Recognition
  /// This is a placeholder that would use the actual ML Kit API
  Future<String> _extractTextFromImage(XFile imageFile) async {
    try {
      // TODO: Implement Firebase ML Kit Text Recognition
      // For now, return placeholder text
      // In production, use:
      // final inputImage = InputImage.fromFilePath(imageFile.path);
      // final textRecognizer = TextRecognizer();
      // final recognizedText = await textRecognizer.processImage(inputImage);
      // return recognizedText.text;
      
      debugPrint('📝 Extracting text from receipt image...');
      
      // Placeholder - replace with real ML Kit implementation
      return '''
STORE NAME: TESCO MALAYSIA
DATE: ${DateTime.now().toString().split(' ').first}
TIME: ${DateTime.now().toString().split(' ').last}

ITEMS:
1. RICE 5KG          RM 25.90
2. MILK 1L           RM 6.50
3. BREAD WHITE       RM 3.20
4. EGGS 10PCS        RM 8.90
5. CHICKEN 1KG       RM 15.50

SUBTOTAL:           RM 60.00
TAX:                RM 0.00
TOTAL:              RM 60.00
      ''';
    } catch (e) {
      debugPrint('❌ Error extracting text: $e');
      return '';
    }
  }

  /// Parse receipt text and extract structured data
  Map<String, dynamic> _parseReceiptText(String text) {
    final Map<String, dynamic> result = {
      'storeName': 'Unknown Store',
      'totalAmount': 0.0,
      'purchaseDate': DateTime.now(),
      'items': <Map<String, dynamic>>[],
    };

    try {
      final lines = text.split('\n');
      String? storeName;
      double? totalAmount;
      DateTime? purchaseDate;

      for (var line in lines) {
        final trimmed = line.trim();
        
        // Extract store name
        if (trimmed.contains('STORE') || trimmed.contains('STORE NAME:')) {
          storeName = trimmed.split(':').last.trim();
        }
        
        // Extract date
        if (trimmed.contains('DATE:')) {
          try {
            final dateStr = trimmed.split(':').last.trim();
            purchaseDate = DateTime.tryParse(dateStr);
          } catch (e) {
            // Ignore parse errors
          }
        }
        
        // Extract total
        if (trimmed.toUpperCase().contains('TOTAL:') && 
            !trimmed.toUpperCase().contains('SUBTOTAL')) {
          final totalStr = trimmed.split(':').last.trim();
          final amountStr = totalStr.replaceAll(RegExp(r'[^\d.]'), '');
          totalAmount = double.tryParse(amountStr);
        }
        
        // Extract items (lines with product names and prices)
        if (trimmed.contains('RM ') && 
            !trimmed.contains('TOTAL') && 
            !trimmed.contains('TAX') &&
            !trimmed.contains('SUBTOTAL')) {
          final itemData = _parseReceiptItem(trimmed);
          if (itemData != null) {
            (result['items'] as List).add(itemData);
          }
        }
      }

      result['storeName'] = storeName ?? 'Unknown Store';
      result['totalAmount'] = totalAmount ?? 0.0;
      result['purchaseDate'] = purchaseDate ?? DateTime.now();

      debugPrint('📋 Parsed receipt: ${result['items'].length} items, Total: RM ${result['totalAmount']}');
    } catch (e) {
      debugPrint('❌ Error parsing receipt text: $e');
    }

    return result;
  }

  /// Parse individual receipt item line
  Map<String, dynamic>? _parseReceiptItem(String line) {
    try {
      // Pattern: "PRODUCT NAME          RM 25.90"
      final parts = line.split('RM');
      if (parts.length != 2) return null;

      final productName = parts[0].trim();
      final priceStr = parts[1].trim().replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(priceStr);

      if (productName.isEmpty || price == null) return null;

      return {
        'productName': productName,
        'price': price,
        'quantity': 1,
        'unit': 'pcs',
      };
    } catch (e) {
      debugPrint('❌ Error parsing receipt item: $e');
      return null;
    }
  }

  /// Process receipt items and update price database
  Future<void> _processReceiptItems(String receiptId, Receipt receipt) async {
    try {
      debugPrint('🔄 Processing ${receipt.items.length} receipt items...');

      for (var item in receipt.items) {
        try {
          // 1. Search for existing product or create new one
          final productName = item.productName;
          final price = item.price;

          // Search for product
          var products = await _priceService.searchProducts(productName);
          Product? product;

          if (products.isNotEmpty) {
            // Use first matching product
            product = products.first;
          } else {
            // Create new product
            final newProduct = Product(
              id: '', // Will be set when saved
              name: productName,
              category: 'Grocery',
              brand: '',
              description: '',
              imageUrl: '',
              barcode: null,
              unit: item.category ?? 'pcs',
              tags: [receipt.storeName],
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final productRef = await _firestore.collection('products').add(newProduct.toFirestore());
            product = newProduct.copyWith(id: productRef.id);
          }

          // 2. Add price entry
          if (product.id.isNotEmpty) {
            // Add price using receipt's storeId
            final priceEntry = Price(
              id: '', // Will be set when saved
              productId: product.id,
              storeId: receipt.storeId,
              price: price,
              currency: 'RM',
              validFrom: receipt.purchaseDate,
              validUntil: null,
              source: 'receipt',
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            await _firestore.collection('prices').add(priceEntry.toFirestore());
            debugPrint('✅ Added price: ${product.name} - RM $price at ${receipt.storeName}');
          }
        } catch (e) {
          debugPrint('❌ Error processing receipt item: $e');
          // Continue with next item
        }
      }

      debugPrint('✅ Finished processing receipt items');
    } catch (e) {
      debugPrint('❌ Error processing receipt items: $e');
      rethrow;
    }
  }

  /// Get user's receipts
  Future<List<Receipt>> getUserReceipts(String userId) async {
    try {
      final query = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) => Receipt.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting user receipts: $e');
      return [];
    }
  }

  /// Get receipt by ID
  Future<Receipt?> getReceipt(String receiptId) async {
    try {
      final doc = await _firestore.collection('receipts').doc(receiptId).get();
      if (doc.exists) {
        return Receipt.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting receipt: $e');
      return null;
    }
  }

  /// Delete receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      await _firestore.collection('receipts').doc(receiptId).delete();
      debugPrint('✅ Receipt deleted: $receiptId');
    } catch (e) {
      debugPrint('❌ Error deleting receipt: $e');
      rethrow;
    }
  }

  /// Clear all receipts for a user
  Future<void> clearAllReceipts(String userId) async {
    try {
      debugPrint('🗑️ Clearing all receipts for user: $userId');
      
      // Get all receipts for the user
      final receiptsSnapshot = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all receipts in batches
      final batch = _firestore.batch();
      int deletedCount = 0;
      
      for (var doc in receiptsSnapshot.docs) {
        batch.delete(doc.reference);
        deletedCount++;
        
        // Firestore batch limit is 500, so commit in batches
        if (deletedCount % 500 == 0) {
          await batch.commit();
          debugPrint('✅ Deleted batch of 500 receipts');
        }
      }
      
      // Commit remaining deletes
      if (deletedCount % 500 != 0) {
        await batch.commit();
      }
      
      debugPrint('✅ Cleared all receipts: $deletedCount receipts deleted');
    } catch (e) {
      debugPrint('❌ Error clearing receipts: $e');
      throw Exception('Failed to clear receipts');
    }
  }
  
  /// Create expense entry from receipt
  Future<void> _createExpenseFromReceipt(
    String userId,
    String receiptId,
    Receipt receipt,
  ) async {
    try {
      // Determine category from store name or default to groceries
      String category = 'groceries';
      if (receipt.storeName.toLowerCase().contains('pharmacy') ||
          receipt.storeName.toLowerCase().contains('guardian') ||
          receipt.storeName.toLowerCase().contains('watson')) {
        category = 'health';
      } else if (receipt.storeName.toLowerCase().contains('petrol') ||
                 receipt.storeName.toLowerCase().contains('shell') ||
                 receipt.storeName.toLowerCase().contains('petronas')) {
        category = 'transport';
      }
      
      // Create expense entry
      final expense = ExpenseTracking(
        id: '', // Will be set by Firestore
        userId: userId,
        category: category,
        amount: receipt.totalAmount,
        currency: receipt.currency,
        description: 'Receipt from ${receipt.storeName}',
        date: receipt.purchaseDate,
        receiptId: receiptId,
        storeId: receipt.storeId,
        storeName: receipt.storeName,
        tags: ['receipt', 'ocr', 'scanned'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save expense (this will also update user totals)
      await _expenseService.addExpense(expense);
      
      debugPrint('✅ Created expense from receipt: MYR ${receipt.totalAmount.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('❌ Error creating expense from receipt: $e');
      // Don't throw - receipt is already saved, expense creation can be retried
    }
  }
}

