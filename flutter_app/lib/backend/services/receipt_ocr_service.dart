import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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

  /// Extract receipt data from image without saving (for preview)
  Future<Map<String, dynamic>> extractReceiptData({
    required XFile imageFile,
    String? storeName,
    DateTime? purchaseDate,
  }) async {
    try {
      debugPrint('📸 Extracting receipt data: ${imageFile.path}');

      // 1. Extract text from receipt
      final extractedText = await _extractTextFromImage(imageFile);

      // 2. Parse receipt data from extracted text
      final receiptData = _parseReceiptText(extractedText);

      // 3. Use provided store name or extracted one
      final storeNameFinal = storeName ?? receiptData['storeName'] ?? 'Unknown Store';

      // 4. Create receipt items
      final receiptItems = (receiptData['items'] as List<dynamic>?)
          ?.map((item) => {
                'productName': item['productName'] as String,
                'price': (item['price'] as num).toDouble(),
                'quantity': item['quantity'] as int? ?? 1,
                'category': item['category'] as String?,
              })
          .toList() ?? [];

      return {
        'storeName': storeNameFinal,
        'totalAmount': receiptData['totalAmount'] ?? 0.0,
        'purchaseDate': purchaseDate ?? receiptData['purchaseDate'] ?? DateTime.now(),
        'items': receiptItems,
        'ocrText': extractedText,
      };
    } catch (e) {
      debugPrint('❌ Error extracting receipt data: $e');
      return {
        'storeName': storeName ?? 'Unknown Store',
        'totalAmount': 0.0,
        'purchaseDate': purchaseDate ?? DateTime.now(),
        'items': <Map<String, dynamic>>[],
        'ocrText': '',
      };
    }
  }

  /// Process receipt image and extract product data (saves to Firebase)
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

  /// Extract text from receipt image using Google ML Kit
  /// Includes image quality checks and error handling
  Future<String> _extractTextFromImage(XFile imageFile) async {
    TextRecognizer? textRecognizer;
    try {
      debugPrint('📝 Starting OCR processing: ${imageFile.path}');
      
      // Check if image file exists
      final file = File(imageFile.path);
      if (!await file.exists()) {
        debugPrint('❌ Image file does not exist: ${imageFile.path}');
        return '';
      }

      // Check file size (too large images may cause issues)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        debugPrint('⚠️ Image file is too large: ${fileSize / 1024 / 1024}MB');
      }

      // Initialize text recognizer
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      // Create input image from file path
      final inputImage = InputImage.fromFilePath(imageFile.path);
      
      // Process image with OCR
      debugPrint('🔍 Processing image with ML Kit...');
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // Extract text from recognized blocks
      String extractedText = recognizedText.text;
      
      // Log statistics
      debugPrint('✅ OCR completed successfully');
      debugPrint('📊 Text blocks found: ${recognizedText.blocks.length}');
      debugPrint('📝 Total characters: ${extractedText.length}');
      
      // If text is too short, it might be a low-quality scan
      if (extractedText.length < 10) {
        debugPrint('⚠️ Warning: Very short text extracted (${extractedText.length} chars). Image quality may be low.');
      }
      
      // Clean up recognizer
      await textRecognizer.close();
      
      return extractedText;
    } on PlatformException catch (e) {
      debugPrint('❌ Platform error during OCR: ${e.message}');
      debugPrint('💡 This might be due to missing ML Kit dependencies');
      return '';
    } catch (e) {
      debugPrint('❌ Error processing receipt image: $e');
      debugPrint('💡 Falling back to manual entry');
      return '';
    } finally {
      // Ensure recognizer is closed even if error occurs
      try {
        await textRecognizer?.close();
      } catch (e) {
        debugPrint('⚠️ Error closing text recognizer: $e');
      }
    }
  }

  /// Parse receipt text and extract structured data
  /// Handles various receipt formats from Malaysian stores
  /// Improved with better pattern matching and confidence scoring
  Map<String, dynamic> _parseReceiptText(String text) {
    final Map<String, dynamic> result = {
      'storeName': 'Unknown Store',
      'totalAmount': 0.0,
      'purchaseDate': DateTime.now(),
      'items': <Map<String, dynamic>>[],
    };

    try {
      if (text.isEmpty) {
        debugPrint('⚠️ Empty text received from OCR');
        return result;
      }

      // Preprocess text: normalize whitespace and clean up
      text = _preprocessReceiptText(text);
      debugPrint('📄 Preprocessed text length: ${text.length}');

      final lines = text.split('\n');
      String? storeName;
      double? totalAmount;
      DateTime? purchaseDate;
      final List<String> itemLines = [];

      // Common Malaysian store names to detect
      final storePatterns = [
        'TESCO', 'AEON', 'GIANT', 'LOTUS', 'MYDIN', 'NSK', 'JAYA GROCER',
        'VILLAGE GROCER', 'COLD STORAGE', '99 SPEEDMART', 'ECONSAVE',
        'HERO MARKET', 'THE STORE', 'PACIFIC', 'BIG', 'BEN\'S'
      ];

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();
        final upperTrimmed = trimmed.toUpperCase();
        
        if (trimmed.isEmpty) continue;

        // Extract store name (usually in first few lines)
        if (i < 5 && storeName == null) {
          for (var pattern in storePatterns) {
            if (upperTrimmed.contains(pattern)) {
              storeName = trimmed;
              // Try to get full store name from next line if available
              if (i + 1 < lines.length) {
                final nextLine = lines[i + 1].trim();
                if (nextLine.isNotEmpty && nextLine.length < 50) {
                  storeName = '$trimmed $nextLine';
                }
              }
              break;
            }
          }
        }
        
        // Extract date (various formats)
        if (purchaseDate == null) {
          // Look for date patterns: DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
          final datePattern = RegExp(r'(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})');
          final dateMatch = datePattern.firstMatch(trimmed);
          if (dateMatch != null) {
            try {
              final day = int.parse(dateMatch.group(1)!);
              final month = int.parse(dateMatch.group(2)!);
              final yearStr = dateMatch.group(3)!;
              final year = yearStr.length == 2 ? 2000 + int.parse(yearStr) : int.parse(yearStr);
              purchaseDate = DateTime(year, month, day);
            } catch (e) {
              // Try parsing as ISO date
              purchaseDate = DateTime.tryParse(trimmed);
            }
          }
        }
        
        // Extract total (look for "TOTAL", "AMOUNT", "GRAND TOTAL", etc.)
        if (totalAmount == null) {
          if (upperTrimmed.contains('TOTAL') && 
              !upperTrimmed.contains('SUBTOTAL') &&
              !upperTrimmed.contains('TAX')) {
            // Try various patterns: "TOTAL: RM 123.45", "TOTAL RM123.45", "TOTAL 123.45"
            final totalPatterns = [
              RegExp(r'TOTAL[:\s]*RM?\s*([\d,]+\.?\d*)', caseSensitive: false),
              RegExp(r'TOTAL[:\s]+([\d,]+\.?\d*)', caseSensitive: false),
            ];
            
            for (var pattern in totalPatterns) {
              final match = pattern.firstMatch(trimmed);
              if (match != null) {
                final amountStr = match.group(1)!.replaceAll(',', '');
                totalAmount = double.tryParse(amountStr);
                if (totalAmount != null) break;
              }
            }
          }
        }
        
        // Detect items section (lines with prices)
        // Items usually have: product name + price (RM X.XX)
        final pricePattern = RegExp(r'RM\s*([\d,]+\.?\d*)', caseSensitive: false);
        final hasPrice = pricePattern.hasMatch(trimmed);
        
        // Skip header lines and totals
        if (hasPrice && 
            !upperTrimmed.contains('TOTAL') && 
            !upperTrimmed.contains('TAX') &&
            !upperTrimmed.contains('SUBTOTAL') &&
            !upperTrimmed.contains('CHANGE') &&
            !upperTrimmed.contains('CASH') &&
            !upperTrimmed.contains('BALANCE') &&
            trimmed.length > 3) {
          itemLines.add(trimmed);
        }
      }

      // Parse items using enhanced parser
      for (var itemLine in itemLines) {
        // Try enhanced parser first
        var itemData = _parseReceiptItemEnhanced(itemLine);
        // Fallback to original parser if enhanced fails
        if (itemData == null) {
          itemData = _parseReceiptItem(itemLine);
        }
        if (itemData != null) {
          (result['items'] as List).add(itemData);
        }
      }

      result['storeName'] = storeName ?? _extractStoreNameFromText(text) ?? 'Unknown Store';
      result['totalAmount'] = totalAmount ?? _extractTotalFromText(text);
      result['purchaseDate'] = purchaseDate ?? DateTime.now();

      debugPrint('📋 Parsed receipt: ${result['items'].length} items, Total: RM ${result['totalAmount']}');
      debugPrint('🏪 Store: ${result['storeName']}');
    } catch (e) {
      debugPrint('❌ Error parsing receipt text: $e');
    }

    return result;
  }

  /// Extract store name from text using heuristics
  String? _extractStoreNameFromText(String text) {
    final storePatterns = [
      'TESCO', 'AEON', 'GIANT', 'LOTUS', 'MYDIN', 'NSK', 'JAYA GROCER',
      'VILLAGE GROCER', 'COLD STORAGE', '99 SPEEDMART', 'ECONSAVE'
    ];
    
    final lines = text.split('\n');
    for (var i = 0; i < lines.length && i < 10; i++) {
      final upperLine = lines[i].toUpperCase();
      for (var pattern in storePatterns) {
        if (upperLine.contains(pattern)) {
          return lines[i].trim();
        }
      }
    }
    return null;
  }

  /// Extract total amount from text using various patterns
  double _extractTotalFromText(String text) {
    final totalPatterns = [
      RegExp(r'TOTAL[:\s]*RM?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'AMOUNT[:\s]*RM?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'GRAND\s+TOTAL[:\s]*RM?\s*([\d,]+\.?\d*)', caseSensitive: false),
    ];
    
    for (var pattern in totalPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        if (amount != null) return amount;
      }
    }
    return 0.0;
  }

  /// Parse individual receipt item line
  /// Handles various formats: "PRODUCT RM 25.90", "PRODUCT 25.90", etc.
  Map<String, dynamic>? _parseReceiptItem(String line) {
    try {
      // Remove common prefixes like item numbers (1., 2., etc.)
      final cleanedLine = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      
      // Try pattern: "PRODUCT NAME RM 25.90" or "PRODUCT NAME 25.90"
      final pricePattern = RegExp(r'RM\s*([\d,]+\.?\d*)', caseSensitive: false);
      final match = pricePattern.firstMatch(cleanedLine);
      
      if (match == null) {
        // Try without RM prefix: "PRODUCT 25.90"
        final numberPattern = RegExp(r'([\d,]+\.?\d{2})\s*$');
        final numberMatch = numberPattern.firstMatch(cleanedLine);
        if (numberMatch == null) return null;
        
        final priceStr = numberMatch.group(1)!.replaceAll(',', '');
        final price = double.tryParse(priceStr);
        if (price == null || price <= 0) return null;
        
        final productName = cleanedLine.substring(0, numberMatch.start).trim();
        if (productName.isEmpty || productName.length < 2) return null;
        
        return {
          'productName': productName,
          'price': price,
          'quantity': _extractQuantity(productName),
          'unit': _extractUnit(productName),
        };
      }
      
      final priceStr = match.group(1)!.replaceAll(',', '');
      final price = double.tryParse(priceStr);
      if (price == null || price <= 0) return null;
      
      final productName = cleanedLine.substring(0, match.start).trim();
      if (productName.isEmpty || productName.length < 2) return null;
      
      // Skip if it looks like a total line
      if (productName.toUpperCase().contains('TOTAL') ||
          productName.toUpperCase().contains('TAX') ||
          productName.toUpperCase().contains('SUBTOTAL')) {
        return null;
      }
      
      return {
        'productName': productName,
        'price': price,
        'quantity': _extractQuantity(productName),
        'unit': _extractUnit(productName),
      };
    } catch (e) {
      debugPrint('❌ Error parsing receipt item: $e');
      return null;
    }
  }

  /// Extract quantity from product name (e.g., "2x", "3 pcs")
  int _extractQuantity(String productName) {
    final qtyPattern = RegExp(r'(\d+)\s*[xX]');
    final match = qtyPattern.firstMatch(productName);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }
    return 1;
  }

  /// Extract unit from product name (e.g., "1kg", "500ml", "10pcs")
  String _extractUnit(String productName) {
    final unitPattern = RegExp(r'(\d+)\s*(kg|g|ml|l|pcs|pc|pkt|pack)', caseSensitive: false);
    final match = unitPattern.firstMatch(productName);
    if (match != null) {
      return match.group(2)!.toLowerCase();
    }
    return 'pcs';
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

  /// Preprocess receipt text to improve parsing accuracy
  /// Normalizes whitespace, fixes common OCR errors, and cleans up text
  String _preprocessReceiptText(String text) {
    // Replace multiple spaces/newlines with single ones
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Fix common OCR errors
    text = text.replaceAll(RegExp(r'[|]'), 'I'); // | to I
    text = text.replaceAll(RegExp(r'[0O]'), '0'); // O to 0 in numbers
    text = text.replaceAll(RegExp(r'[Il1]'), '1'); // I/l to 1 in numbers
    
    // Normalize line breaks
    text = text.replaceAll(RegExp(r'\r\n'), '\n');
    text = text.replaceAll(RegExp(r'\r'), '\n');
    
    // Remove excessive line breaks (more than 2 consecutive)
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Trim each line
    final lines = text.split('\n');
    text = lines.map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n');
    
    return text;
  }

  /// Enhanced item parsing with better pattern matching
  /// Handles more receipt formats and edge cases
  Map<String, dynamic>? _parseReceiptItemEnhanced(String line) {
    try {
      // Remove common prefixes like item numbers (1., 2., etc.)
      String cleanedLine = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      
      // Skip empty lines
      if (cleanedLine.isEmpty) return null;
      
      // Skip header/footer lines
      final upperLine = cleanedLine.toUpperCase();
      if (upperLine.contains('TOTAL') ||
          upperLine.contains('TAX') ||
          upperLine.contains('SUBTOTAL') ||
          upperLine.contains('CHANGE') ||
          upperLine.contains('CASH') ||
          upperLine.contains('BALANCE') ||
          upperLine.contains('VOUCHER') ||
          upperLine.contains('DISCOUNT') ||
          upperLine.contains('PAYMENT') ||
          upperLine.contains('RECEIPT') ||
          upperLine.contains('INVOICE') ||
          upperLine.contains('DATE') ||
          upperLine.contains('TIME') ||
          upperLine.contains('STORE') ||
          upperLine.contains('BRANCH')) {
        return null;
      }
      
      // Try multiple price patterns
      final pricePatterns = [
        // Pattern 1: "PRODUCT NAME RM 25.90"
        RegExp(r'RM\s*([\d,]+\.?\d*)', caseSensitive: false),
        // Pattern 2: "PRODUCT NAME 25.90" (number at end)
        RegExp(r'([\d,]+\.?\d{2})\s*$'),
        // Pattern 3: "PRODUCT NAME @ 25.90"
        RegExp(r'@\s*([\d,]+\.?\d*)', caseSensitive: false),
        // Pattern 4: "PRODUCT NAME x2 25.90"
        RegExp(r'x\d+\s+([\d,]+\.?\d*)', caseSensitive: false),
      ];
      
      RegExpMatch? priceMatch;
      int patternIndex = -1;
      
      for (int i = 0; i < pricePatterns.length; i++) {
        final match = pricePatterns[i].firstMatch(cleanedLine);
        if (match != null) {
          priceMatch = match;
          patternIndex = i;
          break;
        }
      }
      
      if (priceMatch == null) return null;
      
      // Extract price
      final priceStr = priceMatch.group(1)!.replaceAll(',', '').replaceAll(' ', '');
      final price = double.tryParse(priceStr);
      
      if (price == null || price <= 0 || price > 100000) {
        // Price seems invalid
        return null;
      }
      
      // Extract product name based on pattern
      String productName;
      if (patternIndex == 0) {
        // Pattern 1: price is in middle or end with "RM"
        productName = cleanedLine.substring(0, priceMatch.start).trim();
      } else {
        // Pattern 2-4: price is at end
        productName = cleanedLine.substring(0, priceMatch.start).trim();
      }
      
      // Clean product name
      productName = productName
          .replaceAll(RegExp(r'RM\s*$'), '')
          .replaceAll(RegExp(r'@\s*$'), '')
          .replaceAll(RegExp(r'x\d+\s*$'), '')
          .trim();
      
      // Validate product name
      if (productName.isEmpty || productName.length < 2) return null;
      
      // Skip if product name is just numbers
      if (RegExp(r'^\d+$').hasMatch(productName)) return null;
      
      // Extract quantity and unit
      final quantity = _extractQuantity(productName);
      final unit = _extractUnit(productName);
      
      return {
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'unit': unit,
        'category': _inferCategory(productName),
      };
    } catch (e) {
      debugPrint('❌ Error parsing receipt item: $e');
      return null;
    }
  }

  /// Infer product category from product name
  String? _inferCategory(String productName) {
    final upperName = productName.toUpperCase();
    
    // Grocery categories
    if (upperName.contains('CHICKEN') || upperName.contains('AYAM') ||
        upperName.contains('BEEF') || upperName.contains('DAGING') ||
        upperName.contains('FISH') || upperName.contains('IKAN')) {
      return 'Meat & Seafood';
    }
    if (upperName.contains('MILK') || upperName.contains('SUSU') ||
        upperName.contains('CHEESE') || upperName.contains('KEJU') ||
        upperName.contains('BUTTER') || upperName.contains('MARGARINE')) {
      return 'Dairy';
    }
    if (upperName.contains('RICE') || upperName.contains('BERAS') ||
        upperName.contains('NOODLE') || upperName.contains('MEE') ||
        upperName.contains('BREAD') || upperName.contains('ROTI')) {
      return 'Grains & Bakery';
    }
    if (upperName.contains('VEGETABLE') || upperName.contains('SAYUR') ||
        upperName.contains('FRUIT') || upperName.contains('BUAH')) {
      return 'Fresh Produce';
    }
    if (upperName.contains('DRINK') || upperName.contains('MINUMAN') ||
        upperName.contains('JUICE') || upperName.contains('WATER')) {
      return 'Beverages';
    }
    if (upperName.contains('SNACK') || upperName.contains('BISCUIT') ||
        upperName.contains('CHIPS') || upperName.contains('CRACKER')) {
      return 'Snacks';
    }
    
    return 'Groceries'; // Default
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

