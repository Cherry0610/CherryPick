import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

// User model matching Firebase User
class AppUser {
  final String uid;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoURL;

  AppUser({
    required this.uid,
    required this.email,
    this.username,
    this.displayName,
    this.photoURL,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}

/// Real Firebase Authentication Service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user as AppUser
  AppUser? get currentAppUser {
    final user = currentUser;
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }

  /// Sign in with email and password
  Future<AppUser> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔐 Signing in user: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      final appUser = AppUser.fromFirebaseUser(userCredential.user!);

      // Check if this is a new user (first time login after signup)
      // Use timeout and make it non-blocking to prevent long waits
      // Only check if user profile exists, don't block login
      _userService.isNewUser(appUser.uid)
          .timeout(const Duration(seconds: 3))
          .then((isNew) {
        if (isNew) {
          debugPrint('👤 New user detected, creating profile...');
          // Create profile in background, don't wait for it
          _userService.createUserProfile(
            userId: appUser.uid,
            email: appUser.email,
          ).catchError((e) {
            debugPrint('⚠️ Error creating profile (non-blocking): $e');
          });
        } else {
          debugPrint('✅ Existing user profile found');
        }
      }).catchError((e) {
        // If check fails or times out, continue login anyway
        debugPrint('⚠️ Could not verify if user is new, continuing login: $e');
        // Try to create profile anyway (it will merge if exists)
        _userService.createUserProfile(
          userId: appUser.uid,
          email: appUser.email,
        ).catchError((e) {
          debugPrint('⚠️ Error creating profile (non-blocking): $e');
        });
      });

      debugPrint('✅ User signed in: ${appUser.uid}');
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign up with email and password
  Future<AppUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? username,
    String? phone,
  }) async {
    try {
      debugPrint('📝 Signing up new user: $email');

      // Check for duplicate email
      await _checkDuplicateEmail(email);
      
      // Check for duplicate phone if provided
      if (phone != null && phone.isNotEmpty) {
        await _checkDuplicatePhone(phone);
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      final appUser = AppUser.fromFirebaseUser(userCredential.user!);

      // Update display name if username provided
      if (username != null && username.isNotEmpty) {
        await userCredential.user!.updateDisplayName(username);
      }

      // Create user profile in Firestore
      await _userService.createUserProfile(
        userId: appUser.uid,
        email: appUser.email,
        username: username,
        phone: phone,
      );

      debugPrint('✅ New user created: ${appUser.uid}');
      return appUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user to delete');

      final userId = user.uid;

      // Delete user data from Firestore
      await _userService.deleteUserAccount(userId);

      debugPrint('✅ User account deleted: $userId');
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Check if user is new (first time after signup)
  Future<bool> isNewUser() async {
    final user = currentUser;
    if (user == null) return false;
    return await _userService.isNewUser(user.uid);
  }

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if email already exists
  Future<void> _checkDuplicateEmail(String email) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final users = await firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      
      if (users.docs.isNotEmpty) {
        throw Exception('This email is already registered. Please sign in instead.');
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      debugPrint('Error checking duplicate email: $e');
      // Don't block signup if check fails, Firebase Auth will catch duplicates
    }
  }

  /// Check if phone number already exists
  Future<void> _checkDuplicatePhone(String phone) async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Normalize phone number (remove spaces, dashes, etc.)
      final normalizedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      
      final users = await firestore
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get();
      
      if (users.docs.isNotEmpty) {
        throw Exception('This phone number is already registered. Please sign in instead.');
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      debugPrint('Error checking duplicate phone: $e');
      // Don't block signup if check fails
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Password is too weak. Please use a stronger password.');
      case 'email-already-in-use':
        return Exception('This email is already registered. Please sign in instead.');
      case 'invalid-email':
        return Exception('Invalid email address. Please check and try again.');
      case 'user-not-found':
        return Exception('No account found with this email. Please sign up first.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'user-disabled':
        return Exception('This account has been disabled. Please contact support.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed. Please contact support.');
      default:
        return Exception(e.message ?? 'An error occurred. Please try again.');
    }
  }
}