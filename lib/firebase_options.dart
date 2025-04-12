import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Only Web is currently supported.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDJAYv7s8gm-dZktt8MSUA3wtPjY_2aRCU",
    appId: "1:961549171933:web:852a5bcb17906d02072f34",
    messagingSenderId: "961549171933",
    projectId: "my-finance-app-feda1",
    authDomain: "my-finance-app-feda1.firebaseapp.com",
    storageBucket: "my-finance-app-feda1.appspot.com",
    measurementId: "G-DMESLWGXDT",
  );
}
