import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isNewUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return !userDoc.exists;
    } catch (e) {
      debugPrint('Error checking if user is new: $e');
      return true;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? username,
    String? phone,
    String? language,
    String? profileImageUrl,
  }) async {
    try {
      final userData = <String, dynamic>{
        'email': email.toLowerCase().trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Initialize new user with 0 values
        'wishlistCount': 0,
        'totalSaved': 0.0,
        'purchaseCount': 0,
        'expenseCount': 0,
        'totalExpenses': 0.0,
      };
      if (username != null && username.isNotEmpty) userData['username'] = username;
      if (phone != null && phone.isNotEmpty) {
        // Normalize phone number
        userData['phone'] = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      }
      if (language != null && language.isNotEmpty) userData['language'] = language;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) userData['profileImageUrl'] = profileImageUrl;
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
      debugPrint('✅ User profile created/updated: $userId');
      debugPrint('   Initialized with: wishlistCount=0, totalSaved=0.0, purchaseCount=0');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) return userDoc.data();
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? email,
    String? phone,
    String? language,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
      if (username != null && username.isNotEmpty) updateData['username'] = username;
      if (email != null && email.isNotEmpty) updateData['email'] = email;
      if (phone != null && phone.isNotEmpty) updateData['phone'] = phone;
      if (language != null && language.isNotEmpty) updateData['language'] = language;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) updateData['profileImageUrl'] = profileImageUrl;
      await _firestore.collection('users').doc(userId).update(updateData);
      debugPrint('✅ User profile updated: $userId');
      debugPrint('   Username: $username, Email: $email, Phone: $phone, Language: $language');
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  Future<String?> getUserLanguage(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?['language'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUserAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _firestore.collection('wishlists').doc(userId).delete();
      final expensesSnapshot = await _firestore.collection('expenses').where('userId', isEqualTo: userId).get();
      for (var doc in expensesSnapshot.docs) {
        await doc.reference.delete();
      }
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) await user.delete();
      debugPrint('✅ User account deleted: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user account: $e');
      rethrow;
    }
  }
}
