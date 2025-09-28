import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {


    await _initializeLocalNotifications();

    await _initializeFirebaseMessaging();

    _setupMessageHandlers();

  }


  static Future<void> _initializeLocalNotifications() async {

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );


    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );


    await _createNotificationChannels();


  }


  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel bookingChannel = AndroidNotificationChannel(
      'booking_notifications',
      'Booking Notifications',
      description: 'Notifications for ticket bookings',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const AndroidNotificationChannel journeyChannel = AndroidNotificationChannel(
      'journey_reminders',
      'Journey Reminders',
      description: 'Reminders for upcoming journeys',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );


    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(bookingChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(journeyChannel);


  }


  static Future<void> _initializeFirebaseMessaging() async {
    print('Setting up Firebase messaging...');


    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );


  }

  // Set up message handlers
  static void _setupMessageHandlers() {
    print('Setting up message handlers...');


    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _handleInitialMessage();


  }


  static Future<void> _handleForegroundMessage(RemoteMessage message) async {

    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }


  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    print('Background data: ${message.data}');


  }


  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    print(' Tap data: ${message.data}');

    _navigateBasedOnNotification(message.data);
  }


  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('App opened from terminated state via notification');
      print('Initial message data: ${initialMessage.data}');
      _navigateBasedOnNotification(initialMessage.data);
    }
  }


  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    final Map<String, dynamic> data = message.data;

    if (title == null || body == null) return;


    String notificationType = data['type'] ?? 'general';
    String channelId = _getChannelId(notificationType);


    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(notificationType),
      channelDescription: _getChannelDescription(notificationType),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );


    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );


  }

  static void _onNotificationTapped(NotificationResponse response) {


    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateBasedOnNotification(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  static void _navigateBasedOnNotification(Map<String, dynamic> data) {
    String notificationType = data['type'] ?? '';

    switch (notificationType) {
      case 'booking_confirmation':

        String? ticketId = data['ticketId'];
        if (ticketId != null) {

          print('Should navigate to ticket: $ticketId');
        }
        break;

      case 'journey_reminder':
        print(' Should navigate to journey details');
        break;

      case 'booking_error':
        print('Should show booking error');
        break;

      default:
        print('Default navigation to home');
        break;
    }
  }

  static String _getChannelId(String type) {
    switch (type) {
      case 'booking_confirmation':
      case 'booking_error':
        return 'booking_notifications';
      case 'journey_reminder':
        return 'journey_reminders';
      default:
        return 'general_notifications';
    }
  }

  static String _getChannelName(String type) {
    switch (type) {
      case 'booking_confirmation':
      case 'booking_error':
        return 'Booking Notifications';
      case 'journey_reminder':
        return 'Journey Reminders';
      default:
        return 'General Notifications';
    }
  }

  static String _getChannelDescription(String type) {
    switch (type) {
      case 'booking_confirmation':
      case 'booking_error':
        return 'Notifications related to ticket bookings';
      case 'journey_reminder':
        return 'Reminders for upcoming journeys';
      default:
        return 'General app notifications';
    }
  }
}


Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print(' Background message received: ${message.messageId}');

}