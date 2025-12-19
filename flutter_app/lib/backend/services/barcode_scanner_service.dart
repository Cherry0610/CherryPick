import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'price_comparison_service.dart';
import '../models/product.dart';

/// Real barcode scanner service for product identification
class BarcodeScannerService {
  final PriceComparisonService _priceService = PriceComparisonService();
  final ImagePicker _imagePicker = ImagePicker();

  /// Scan barcode from camera
  Future<Product?> scanBarcodeFromCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Take picture
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      // Extract barcode from image
      // TODO: Implement ML Kit Barcode Scanner
      // For now, return null - user can manually enter barcode
      debugPrint('📷 Image captured: ${image.path}');
      debugPrint('⚠️ Barcode scanning not yet implemented - use manual input');
      
      return null;
    } catch (e) {
      debugPrint('❌ Error scanning barcode: $e');
      rethrow;
    }
  }

  /// Search product by barcode
  Future<Product?> searchByBarcode(String barcode) async {
    try {
      if (barcode.trim().isEmpty) return null;

      debugPrint('🔍 Searching product by barcode: $barcode');

      // Search in local database
      final products = await _priceService.searchProducts(barcode);
      
      // Filter by exact barcode match
      for (var product in products) {
        if (product.barcode?.toLowerCase() == barcode.toLowerCase()) {
          return product;
        }
      }

      // If not found locally, search in grocery stores
      // Grocery stores might have barcode lookup
      debugPrint('⚠️ Product not found with barcode: $barcode');
      return null;
    } catch (e) {
      debugPrint('❌ Error searching by barcode: $e');
      return null;
    }
  }

  /// Validate barcode format
  bool isValidBarcode(String barcode) {
    // EAN-13, EAN-8, UPC-A, UPC-E formats
    final barcodePattern = RegExp(r'^\d{8,13}$');
    return barcodePattern.hasMatch(barcode);
  }
}


