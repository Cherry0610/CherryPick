import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static bool get isPlaceholder => false;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCArmB7lV_ew6WLoeh_a0dzKSPAbuMNduI',
    appId: '1:776290376233:web:cherrypick_web',
    messagingSenderId: '776290376233',
    projectId: 'cherrypick-67246',
    authDomain: 'cherrypick-67246.firebaseapp.com',
    storageBucket: 'cherrypick-67246.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCArmB7lV_ew6WLoeh_a0dzKSPAbuMNduI',
    appId: '1:776290376233:android:cherrypick_android',
    messagingSenderId: '776290376233',
    projectId: 'cherrypick-67246',
    storageBucket: 'cherrypick-67246.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCArmB7lV_ew6WLoeh_a0dzKSPAbuMNduI',
    appId: '1:776290376233:ios:d8941b4d22d20390c3da38',
    messagingSenderId: '776290376233',
    projectId: 'cherrypick-67246',
    storageBucket: 'cherrypick-67246.firebasestorage.app',
    iosClientId: '776290376233.apps.googleusercontent.com',
    iosBundleId: 'com.cherrypick.cherrypickApp',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}
