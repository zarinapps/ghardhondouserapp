import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrRJxhlgvrH-I6RH3WUcgbLbu7su277WY',
    appId: '1:783912667881:android:15b292b078ab907d907e78',
    messagingSenderId: '783912667881',
    projectId: 'ghardhondo-8899f',
    storageBucket: 'ghardhondo-8899f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsuxFQVKBoURt070e56_GxUWDglHGT5d0',
    appId: '1:63168540332:ios:0d980b41297ce2ef623909',
    messagingSenderId: '63168540332',
    projectId: 'ebroker-wrteam',
    storageBucket: 'ebroker-wrteam.appspot.com',
    androidClientId:
        '63168540332-bf5kqt19bbbq0ub3quibe67tfi7hjc1v.apps.googleusercontent.com',
    iosClientId:
        '63168540332-b8snl3ggfeaosrq8acqc11npalhouus5.apps.googleusercontent.com',
    iosBundleId: 'com.ebroker.wrteam',
  );
}