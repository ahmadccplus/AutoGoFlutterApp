// File generated using FlutterFire CLI.
// To configure Firebase for your project, run:
// flutterfire configure
//
// Or manually update this file with your Firebase project configuration.
// You can get your configuration from Firebase Console > Project Settings > General > Your apps

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAjuwxjO_49PPytl3vGVzcLb9CzqsqunRg',
    appId: '1:660428197742:web:010ae21c2c2b7b4e1d3b7f',
    messagingSenderId: '660428197742',
    projectId: 'autogoflutterapp',
    authDomain: 'autogoflutterapp.firebaseapp.com',
    storageBucket: 'autogoflutterapp.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyKFuqK7ngWy0sAJCmfsZXeCFs6LjGgr0',
    appId: '1:660428197742:android:14716b68792b39141d3b7f',
    messagingSenderId: '660428197742',
    projectId: 'autogoflutterapp',
    storageBucket: 'autogoflutterapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBtUy3RmpPEcnSesU0q2zhDlS8r4V62nM',
    appId: '1:660428197742:ios:815229e9972c27301d3b7f',
    messagingSenderId: '660428197742',
    projectId: 'autogoflutterapp',
    storageBucket: 'autogoflutterapp.firebasestorage.app',
    iosBundleId: 'com.autogo.autogo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBtUy3RmpPEcnSesU0q2zhDlS8r4V62nM',
    appId: '1:660428197742:ios:815229e9972c27301d3b7f',
    messagingSenderId: '660428197742',
    projectId: 'autogoflutterapp',
    storageBucket: 'autogoflutterapp.firebasestorage.app',
    iosBundleId: 'com.autogo.autogo',
  );
}




