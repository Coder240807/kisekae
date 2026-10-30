import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kisekae/firebase_options.dart';

import 'notification_constants.dart';
import 'notification_helpers.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(
          NotificationConstants.androidIcon,
        ),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await NotificationHelpers.showNotification(message, plugin);
  } catch (e) {
    debugPrint('Background error: $e');
  }
}
