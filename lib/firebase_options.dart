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
    apiKey: 'AIzaSyCpS4L1eZx7pIcmo5rG1vaRepIJstIZzew',
    appId: '1:1000405596820:web:3cf185d157171d7def5281',
    messagingSenderId: '1000405596820',
    projectId: 'budgetbuddy-7e959',
    authDomain: 'budgetbuddy-7e959.firebaseapp.com',
    storageBucket: 'budgetbuddy-7e959.firebasestorage.app',
    measurementId: 'G-QQ2CG7450L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-vr_oLiMU31EdsqL5x0ZpVd44iKmdCSE',
    appId: '1:1000405596820:android:5f56ffe0828d0aa9ef5281',
    messagingSenderId: '1000405596820',
    projectId: 'budgetbuddy-7e959',
    storageBucket: 'budgetbuddy-7e959.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1QdFIX-VqsXT0zdNMI09m89_MXEIbuMo',
    appId: '1:1000405596820:ios:c534afc43bb331c9ef5281',
    messagingSenderId: '1000405596820',
    projectId: 'budgetbuddy-7e959',
    storageBucket: 'budgetbuddy-7e959.firebasestorage.app',
    iosBundleId: 'com.example.buddgetBuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1QdFIX-VqsXT0zdNMI09m89_MXEIbuMo',
    appId: '1:1000405596820:ios:c534afc43bb331c9ef5281',
    messagingSenderId: '1000405596820',
    projectId: 'budgetbuddy-7e959',
    storageBucket: 'budgetbuddy-7e959.firebasestorage.app',
    iosBundleId: 'com.example.buddgetBuddy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCpS4L1eZx7pIcmo5rG1vaRepIJstIZzew',
    appId: '1:1000405596820:web:9f5bd4bf04401192ef5281',
    messagingSenderId: '1000405596820',
    projectId: 'budgetbuddy-7e959',
    authDomain: 'budgetbuddy-7e959.firebaseapp.com',
    storageBucket: 'budgetbuddy-7e959.firebasestorage.app',
    measurementId: 'G-FSK5SNY28Y',
  );

}