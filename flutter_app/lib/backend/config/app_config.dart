/// App Configuration
class AppConfig {
  // Set this to true to bypass Firebase and use mock authentication for testing
  static const bool useMockAuth = false;

  // Set this to true to show debug information
  static const bool debugMode = true;

  // Firebase configuration
  static const String firebaseProjectId = 'cherrypick-67246';

  // Backend base URL (Node/Express API)
  static const String apiBaseUrl = 'http://localhost:3000/api';

  // Password requirements
  static const int minPasswordLength = 8;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = false;

  // App version
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // Helper method to check if mock auth is enabled
  static bool shouldUseMockAuth() {
    return useMockAuth;
  }

  // Helper method to check if debug mode is enabled
  static bool isDebugMode() {
    return debugMode;
  }
}








