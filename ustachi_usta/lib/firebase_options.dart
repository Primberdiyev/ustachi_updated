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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQdXIUdQQSmOVM-1hVWQJ4dLdhXOdpKqY',
    appId: '1:1013847349146:web:42165ccc4b9c9a3fed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    authDomain: 'ustatop-f3940.firebaseapp.com',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
    measurementId: 'G-TBNJJPSS8E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAANEqG6o9TDaQibnF4XbSRJuC_swYbHX8',
    appId: '1:1013847349146:android:836029d09b6ae47aed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqd_NWWs35sDAKIYLV8n_fI1c1kZhXGUI',
    appId: '1:1013847349146:ios:17796cab2e2f2ebaed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
    iosBundleId: 'uz.ustachi.master',
  );
}
