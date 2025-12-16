import 'package:flutter/material.dart';

// A simple User model to represent the signed-in user
class User {
  final String uid;
  final String email;
  // Added optional username/displayName field
  final String? username;

  User({required this.uid, required this.email, this.username});
}

class AuthService {
  // Mock function to simulate signing in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    // --- Mock Implementation for Demonstration ---
    debugPrint('Attempting to sign in user: $email');

    // Simple validation (replace with actual backend call)
    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters long.");
    }

    // --- FIX: RELAXED MOCK LOGIN CONDITION ---
    // Change the condition to check if the email contains '@' instead of ending with '@example.com'
    if (email.contains('@')) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      return User(
        uid: 'user-${email.hashCode}',
        email: email,
        username: 'GuestUser', // Mock username for sign-in
      );
    } else {
      // Simulate an error from the backend
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception("Invalid credentials or user not found.");
    }
    // --- End Mock Implementation ---
  }

  // Updated Placeholder for the Sign Up method (now accepts username)
  Future<User?> signUpWithEmailPassword(
      String email,
      String password,
      String username // Added username as a required argument
      ) async {
    debugPrint('Attempting to sign up user: $username ($email)');

    // Simple validation
    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters long.");
    }

    // In a real app, this would register the user in Firebase/backend
    await Future.delayed(const Duration(milliseconds: 1000));

    // Return the newly created user object
    return User(
      uid: 'new-user-${email.hashCode}',
      email: email,
      username: username, // Return the username passed
    );
  }

  // --- NEW MOCK FUNCTION TO FIX THE ERROR ---
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    debugPrint('MOCK: Password reset requested for: $email');

    // Simulate a success case where the email is sent
    if (email.contains('@')) {
      // No action needed for mock success, just return
      return;
    } else {
      // Simulate an error if the email is invalid
      throw Exception("The provided email address is invalid.");
    }
  }
}