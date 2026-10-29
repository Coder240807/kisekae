import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_constants.dart';
import 'notification_helpers.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  static final _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;
  Map<String, dynamic>? _pendingDeepLink;

  final _tapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTap => _tapController.stream;
  Map<String, dynamic>? consumePendingDeepLink() {
    final pending = _pendingDeepLink;
    _pendingDeepLink = null;
    return pending;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _plugin = FlutterLocalNotificationsPlugin();
      await _plugin!.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings(
            NotificationConstants.androidIcon,
          ),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onTap,
      );
      if (Platform.isAndroid) {
        await _createChannel();
      }
      await _setupListeners();
      _initialized = true;
    } catch (e) {
      debugPrint('Init error: $e');
      rethrow;
    }
  }

  Future<void> _createChannel() async {
    final channel = NotificationHelpers.createChannel();
    await _plugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupListeners() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null && initial.data.isNotEmpty) {
      _pendingDeepLink = initial.data;
    }

    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    if (_plugin != null) {
      await NotificationHelpers.showNotification(message, _plugin!);
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _tapController.add(message.data);
    }
  }

  void _onTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _tapController.add(data);
    }
  }

  static Future<String?> getToken() => _messaging.getToken();
  static Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
  static Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  void dispose() {
    _tapController.close();
  }

  Future<void> setupTokenRefresh(Function(String) onTokenReceived) async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('Token refreshed: $newToken');
      onTokenReceived(newToken);
    });
  }
}
