import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);

    // 2. Request Permissions (for Android 13+)
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    // 3. Initialize Firebase Messaging (Background/Terminated)
    await FirebaseMessaging.instance.requestPermission();

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // unique id
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Helper for testing - fetches a real outfit from Firestore
  Future<void> showTestNotification() async {
    String outfitTitle = 'your outfit';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('outfits')
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Pick a random outfit
          final random = Random();
          final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
          final data = randomDoc.data();
          outfitTitle = data['title'] ?? 'your outfit';
        }
      }
    } catch (e) {
      print('Error fetching outfit for notification: $e');
    }

    await showLocalNotification(
      title: 'New Like! ❤️',
      body: 'Someone liked your outfit "$outfitTitle"!',
    );
  }
}
