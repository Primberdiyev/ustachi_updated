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
      default:
        throw UnsupportedError(
          '${defaultTargetPlatform.name} uchun Firebase sozlanmagan.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAANEqG6o9TDaQibnF4XbSRJuC_swYbHX8',
    appId: '1:1013847349146:android:3f687efa716b0bffed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqd_NWWs35sDAKIYLV8n_fI1c1kZhXGUI',
    appId: '1:1013847349146:ios:b1e3dde66b225d05ed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
    iosBundleId: 'com.ustachi.mijoz',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQdXIUdQQSmOVM-1hVWQJ4dLdhXOdpKqY',
    appId: '1:1013847349146:web:42165ccc4b9c9a3fed8c23',
    messagingSenderId: '1013847349146',
    projectId: 'ustatop-f3940',
    authDomain: 'ustatop-f3940.firebaseapp.com',
    storageBucket: 'ustatop-f3940.firebasestorage.app',
    measurementId: 'G-TBNJJPSS8E',
  );
}
