import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for uploading images to Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      debugPrint('📤 Uploading profile picture for user: $userId');

      // Create a reference to the file location
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');

      // Upload the file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Profile picture uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String userId) async {
    try {
      debugPrint('🗑️ Deleting profile picture for user: $userId');
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.delete();
      debugPrint('✅ Profile picture deleted');
    } catch (e) {
      debugPrint('❌ Error deleting profile picture: $e');
      // Don't throw - it's okay if file doesn't exist
    }
  }

  /// Upload image from web (for web platform)
  Future<String> uploadProfilePictureFromWeb({
    required String userId,
    required Uint8List imageData,
  }) async {
    try {
      debugPrint('📤 Uploading profile picture (web) for user: $userId');

      final ref = _storage.ref().child('profile_pictures/$userId.jpg');

      final uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Profile picture uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading profile picture: $e');
      rethrow;
    }
  }
}



