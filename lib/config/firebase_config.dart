import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for different flavors
class FirebaseConfig {
  static final FirebaseOptions devOptions = FirebaseOptions(
    apiKey: 'AIzaSyAPSXP5DYLGvvdvjjCL8FWDEawVJeRI_uY',
    appId: '1:210110813527:ios:b76435247479ff5d7eda12',
    messagingSenderId: '210110813527',
    projectId: 'junto-dev-6a4a8',
    storageBucket: 'junto-dev-6a4a8.firebasestorage.app',
  );

  static final FirebaseOptions prodOptions = FirebaseOptions(
    apiKey: 'AIzaSyAXnKNEn0aDmsL2QXjgy36rsXSXYJHw-b8',
    appId: '1:878364587679:ios:8dc5c646ce1e637f9c14aa',
    messagingSenderId: '878364587679',
    projectId: 'junto-8fdaa',
    storageBucket: 'junto-8fdaa.firebasestorage.app',
  );

  static FirebaseOptions getOptions({required String flavor}) {
    switch (flavor.toLowerCase()) {
      case 'dev':
        return devOptions;
      case 'prod':
      default:
        return prodOptions;
    }
  }
}
