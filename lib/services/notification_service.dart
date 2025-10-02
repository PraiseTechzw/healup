import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import 'database_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure Firebase messaging
    await _configureFirebaseMessaging();
  }

  // Request notification permission
  static Future<bool> _requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configure Firebase messaging
  static Future<void> _configureFirebaseMessaging() async {
    // Request permission for notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();
      print('FCM Token: $token');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap
    print('Local notification tapped: ${response.payload}');
  }

  // Handle foreground message
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'HealUp',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  // Handle notification tap when app is in background
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    // Handle navigation based on notification data
  }

  // Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'healup_channel',
      'HealUp Notifications',
      channelDescription: 'Notifications for HealUp app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Send notification to user
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    String? iconUrl,
  }) async {
    try {
      final notification = NotificationModel(
        id: DatabaseService.generateId(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        priority: priority,
        isRead: false,
        createdAt: DateTime.now(),
        data: data,
        actionUrl: actionUrl,
        imageUrl: imageUrl,
        iconUrl: iconUrl,
      );

      await DatabaseService.createNotification(notification);

      // Show local notification if user is current user
      if (userId == FirebaseAuth.instance.currentUser?.uid) {
        await _showLocalNotification(
          title: title,
          body: body,
          payload: data.toString(),
        );
      }
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  // Send appointment reminder
  static Future<void> sendAppointmentReminder({
    required String userId,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    final title = 'Appointment Reminder';
    final body = 'You have an appointment with Dr. $doctorName at $timeSlot';

    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.appointmentReminder,
      priority: NotificationPriority.high,
      data: {
        'appointmentDate': appointmentDate.toIso8601String(),
        'doctorName': doctorName,
        'timeSlot': timeSlot,
      },
    );
  }

  // Send appointment confirmation
  static Future<void> sendAppointmentConfirmation({
    required String userId,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    final title = 'Appointment Confirmed';
    final body =
        'Your appointment with Dr. $doctorName has been confirmed for $timeSlot';

    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.appointmentConfirmed,
      priority: NotificationPriority.medium,
      data: {
        'appointmentDate': appointmentDate.toIso8601String(),
        'doctorName': doctorName,
        'timeSlot': timeSlot,
      },
    );
  }

  // Send appointment cancellation
  static Future<void> sendAppointmentCancellation({
    required String userId,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
  }) async {
    final title = 'Appointment Cancelled';
    final body =
        'Your appointment with Dr. $doctorName has been cancelled${reason != null ? ': $reason' : ''}';

    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.appointmentCancelled,
      priority: NotificationPriority.medium,
      data: {
        'appointmentDate': appointmentDate.toIso8601String(),
        'doctorName': doctorName,
        'timeSlot': timeSlot,
        'reason': reason,
      },
    );
  }

  // Send prescription ready notification
  static Future<void> sendPrescriptionReady({
    required String userId,
    required String doctorName,
    required String prescriptionId,
  }) async {
    final title = 'Prescription Ready';
    final body = 'Your prescription from Dr. $doctorName is ready for pickup';

    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.prescriptionReady,
      priority: NotificationPriority.high,
      data: {'doctorName': doctorName, 'prescriptionId': prescriptionId},
    );
  }

  // Send test results notification
  static Future<void> sendTestResults({
    required String userId,
    required String testName,
    required String doctorName,
  }) async {
    final title = 'Test Results Available';
    final body =
        'Your $testName results from Dr. $doctorName are now available';

    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.testResults,
      priority: NotificationPriority.high,
      data: {'testName': testName, 'doctorName': doctorName},
    );
  }

  // Send emergency notification
  static Future<void> sendEmergencyNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.emergency,
      priority: NotificationPriority.urgent,
    );
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Failed to subscribe to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Failed to unsubscribe from topic: $e');
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Clear specific notification
  static Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  // Handle background message
}
