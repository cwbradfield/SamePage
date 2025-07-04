// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJ_jXH51r0W9kBldKfphqx7wL8M2LjkpU',
    appId: '1:511172841554:web:ba8c0ec0ce7fcab2b20f8b',
    messagingSenderId: '511172841554',
    projectId: 'samepage-fcc7a',
    authDomain: 'samepage-fcc7a.firebaseapp.com',
    storageBucket: 'samepage-fcc7a.firebasestorage.app',
    measurementId: 'G-9ZBZFL6WZ9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWHgnEoCUy-cPiW39lVp3sh4PZboNjJgs',
    appId: '1:511172841554:android:1237ac47aa2468fab20f8b',
    messagingSenderId: '511172841554',
    projectId: 'samepage-fcc7a',
    storageBucket: 'samepage-fcc7a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWvtkscDKaLK03aVbv1uNPvPSAaRTj-qw',
    appId: '1:511172841554:ios:6d522f0ed523554fb20f8b',
    messagingSenderId: '511172841554',
    projectId: 'samepage-fcc7a',
    storageBucket: 'samepage-fcc7a.firebasestorage.app',
    iosBundleId: 'com.example.socialBookApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWvtkscDKaLK03aVbv1uNPvPSAaRTj-qw',
    appId: '1:511172841554:ios:6d522f0ed523554fb20f8b',
    messagingSenderId: '511172841554',
    projectId: 'samepage-fcc7a',
    storageBucket: 'samepage-fcc7a.firebasestorage.app',
    iosBundleId: 'com.example.socialBookApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJ_jXH51r0W9kBldKfphqx7wL8M2LjkpU',
    appId: '1:511172841554:web:a61ce864440b50beb20f8b',
    messagingSenderId: '511172841554',
    projectId: 'samepage-fcc7a',
    authDomain: 'samepage-fcc7a.firebaseapp.com',
    storageBucket: 'samepage-fcc7a.firebasestorage.app',
    measurementId: 'G-QGHLKTFZ0X',
  );

}