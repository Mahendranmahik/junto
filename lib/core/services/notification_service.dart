import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:junto/modules/auth/services/auth_service.dart';
import 'package:junto/di/locator.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        _navigateToChat(response.payload!);
      }
    },
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

Future<void> _navigateToChat(String senderId) async {
  try {
    if (senderId.isEmpty) return;
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
    
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        Get.toNamed('/chat', arguments: userData);
      }
    }
  } catch (e) {
  }
}

Future<void> setupFirebaseMessaging() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final senderId = message.data['senderId']?.toString() ?? '';
    
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new message',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
          ),
        ),
        payload: senderId,
      );
    } else {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.data['title'] ?? 'Notification',
        message.data['body'] ?? message.data['message'] ?? 'You have a new message',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
          ),
        ),
        payload: senderId,
      );
    }
  });
  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final senderId = message.data['senderId'] as String?;
    if (senderId != null && senderId.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToChat(senderId);
      });
    }
  });
  
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final senderId = message.data['senderId'] as String?;
      if (senderId != null && senderId.isNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          _navigateToChat(senderId);
        });
      }
    }
  });
  
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    final authService = getIt<AuthService>();
    if (authService.currentUser != null) {
      authService.saveFcmToken(newToken);
    }
  });
  
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      final authService = getIt<AuthService>();
      if (authService.currentUser != null) {
        await authService.saveFcmToken(fcmToken);
      }
    }
  } catch (e) {
  }
}

