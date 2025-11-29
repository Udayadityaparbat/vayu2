// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBq0sGF1lR6vb94RVHqQXlVXD3J19Hs9bQ",
    authDomain: "vayu-33599.firebaseapp.com",
    projectId: "vayu-33599",
    storageBucket: "vayu-33599.firebasestorage.app",
    messagingSenderId: "951724403902",
    appId: "1:951724403902:web:7a492582a53c28680f742ef",
    measurementId: "G-YFRXV0149D",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBq0sGF1lR6vb94RVHqQXlVXD3J19Hs9bQ",
    authDomain: "vayu-33599.firebaseapp.com",
    projectId: "vayu-33599",
    storageBucket: "vayu-33599.firebasestorage.app",
    messagingSenderId: "951724403902",
    appId: "1:951724403902:android:64b8e7e73803eea579f42ef",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBq0sGF1lR6vb94RVHqQXlVXD3J19Hs9bQ",
    authDomain: "vayu-33599.firebaseapp.com",
    projectId: "vayu-33599",
    storageBucket: "vayu-33599.firebasestorage.app",
    messagingSenderId: "951724403902",
    appId: "1:951724403902:ios:placeholder",
    iosBundleId: "com.example.vayuApp",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyBq0sGF1lR6vb94RVHqQXlVXD3J19Hs9bQ",
    authDomain: "vayu-33599.firebaseapp.com",
    projectId: "vayu-33599",
    storageBucket: "vayu-33599.firebasestorage.app",
    messagingSenderId: "951724403902",
    appId: "1:951724403902:macos:placeholder",
    iosBundleId: "com.example.vayuApp",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyBq0sGF1lR6vb94RVHqQXlVXD3J19Hs9bQ",
    authDomain: "vayu-33599.firebaseapp.com",
    projectId: "vayu-33599",
    storageBucket: "vayu-33599.firebasestorage.app",
    messagingSenderId: "951724403902",
    appId: "1:951724403902:web:7a492582a53c28680f742ef",
  );
}
