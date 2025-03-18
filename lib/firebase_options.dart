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
    apiKey: 'AIzaSyC46wX-mshbXT08wRVrS-D2TIBotmJNnxY',
    appId: '1:547885866567:web:9d49e04092a10a244d1b62',
    messagingSenderId: '547885866567',
    projectId: 'aiteachingassistant-965a8',
    authDomain: 'aiteachingassistant-965a8.firebaseapp.com',
    databaseURL: 'https://aiteachingassistant-965a8-default-rtdb.firebaseio.com',
    storageBucket: 'aiteachingassistant-965a8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOl8Mm_9rcFAxITwoeZSydZj79x8I6Ldk',
    appId: '1:547885866567:android:940688e289d8da814d1b62',
    messagingSenderId: '547885866567',
    projectId: 'aiteachingassistant-965a8',
    databaseURL: 'https://aiteachingassistant-965a8-default-rtdb.firebaseio.com',
    storageBucket: 'aiteachingassistant-965a8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-qXAThL_RSvG5bhwM7RzRQuJxUimHXMg',
    appId: '1:547885866567:ios:fe1ae7701d2183e14d1b62',
    messagingSenderId: '547885866567',
    projectId: 'aiteachingassistant-965a8',
    databaseURL: 'https://aiteachingassistant-965a8-default-rtdb.firebaseio.com',
    storageBucket: 'aiteachingassistant-965a8.firebasestorage.app',
    iosClientId: '547885866567-qhuooidippklf4vlqgop49sr0cadhcs4.apps.googleusercontent.com',
    iosBundleId: 'com.example.aiTeachingAssistant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD-qXAThL_RSvG5bhwM7RzRQuJxUimHXMg',
    appId: '1:547885866567:ios:fe1ae7701d2183e14d1b62',
    messagingSenderId: '547885866567',
    projectId: 'aiteachingassistant-965a8',
    databaseURL: 'https://aiteachingassistant-965a8-default-rtdb.firebaseio.com',
    storageBucket: 'aiteachingassistant-965a8.firebasestorage.app',
    iosClientId: '547885866567-qhuooidippklf4vlqgop49sr0cadhcs4.apps.googleusercontent.com',
    iosBundleId: 'com.example.aiTeachingAssistant',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC46wX-mshbXT08wRVrS-D2TIBotmJNnxY',
    appId: '1:547885866567:web:13c111b9bcdaff674d1b62',
    messagingSenderId: '547885866567',
    projectId: 'aiteachingassistant-965a8',
    authDomain: 'aiteachingassistant-965a8.firebaseapp.com',
    databaseURL: 'https://aiteachingassistant-965a8-default-rtdb.firebaseio.com',
    storageBucket: 'aiteachingassistant-965a8.firebasestorage.app',
  );
}
