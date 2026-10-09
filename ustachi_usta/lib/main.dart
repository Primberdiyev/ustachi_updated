import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ustachi/application/language_provider.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/services/push/push_navigator.dart';
import 'package:ustachi/core/services/push/push_notification_service.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/firebase_options.dart';
import 'package:ustachi/my_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await LocaleSettings.useDeviceLocale();
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  await setupLocator();
  await StorageRepository.getInstance();
  await LanguageProvider().loadLocale();
  ScriptProvider().load();

  final push = sl<PushNotificationService>();
  final pushNavigator = PushNavigator(sl<AppRouter>());
  push.onOpen = pushNavigator.open;
  push.canOpen = pushNavigator.canOpen;

  unawaited(push.init());

  runApp(
    TranslationProvider(
      child: const MyApp(),
    ),
  );
}
