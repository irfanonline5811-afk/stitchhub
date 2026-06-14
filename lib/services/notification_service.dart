 import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../screens/customer/order_detail_screen.dart';
import '../screens/customer/chat_detail_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  final List<RealtimeChannel> _channels = [];

  // Initialize notifications
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _navigatorKey = navigatorKey;

    if (kIsWeb) {
      debugPrint('NotificationService: Skipping mobile permissions and FCM initialization on Web.');
      return;
    }

    // Request notification permission for Android 13+ and iOS
    await Permission.notification.request();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'stitchhub_high_importance_channel', // Updated ID
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max, // Set to max for popups
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Setup Firebase Messaging
    await _setupFCM();

    debugPrint('NotificationService initialized with FCM');
  }

  // Setup FCM listeners and token management
  Future<void> _setupFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token and save it to Supabase if user is logged in
    try {
      String? token = await messaging.getToken();
      if (token != null && _supabase.auth.currentUser != null) {
        await saveTokenForUser(_supabase.auth.currentUser!.id, token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // Handle background messages (Must be a top-level or static function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground FCM message: ${message.notification?.title}');
      
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle notification tap when app is in background but not killed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Notification tapped while app in background');
      _navigateFromFCM(message);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via FCM');
      _navigateFromFCM(initialMessage);
    }
  }

  // Static handler for background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // This runs in a separate isolate when the app is closed/backgrounded
    debugPrint("Handling a background message: ${message.messageId}");
  }

  void _navigateFromFCM(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      String? type = message.data['type'];
      _navigateFromNotification(type: type, data: message.data);
    }
  }

  // Save token for a specific user
  Future<void> saveTokenForUser(String userId, String token) async {
    try {
      await _supabase.from('users').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('Saved notification token for user: $userId');
    } catch (e) {
      debugPrint('Error saving notification token: $e');
    }
  }

  // Manually update token (useful after login)
  Future<void> updateToken() async {
    if (kIsWeb) return;
    final User? user = _supabase.auth.currentUser;
    if (user != null) {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await saveTokenForUser(user.id, token);
        startRealtimeListeners(user.id); // Also restart listeners for the new user
      }
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stitchhub_high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Helps with some Android versions
      category: AndroidNotificationCategory.message,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static const String _backendBaseUrl = 'http://10.0.2.2:3000/api'; // Use your server IP for physical device

  // Send a general notification via Backend FCM
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 1. Get the target user's FCM token from Supabase
      final userData = await _supabase
          .from('users')
          .select('fcm_token')
          .eq('id', userId)
          .single();
      
      final String? token = userData['fcm_token'];

      if (token == null || token.isEmpty) {
        debugPrint('NotificationService: No FCM token found for user $userId. Simulation only.');
        // Fallback to local if it's the current user (simulation)
        if (_supabase.auth.currentUser?.id == userId) {
          await _showLocalNotification(title: title, body: body, payload: data != null ? jsonEncode(data) : null);
        }
        return;
      }

      // 2. Call the backend to send the actual Push Notification via FCM
      /*
      final response = await _supabase.functions.invoke('send-push', body: {
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
      */

      // Using the Custom Node.js backend:
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/notifications/send-push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        debugPrint('Real Push Notification sent successfully via Backend');
      } else {
        debugPrint('Failed to send Push via Backend: ${response.body}');
      }

      debugPrint('Real Push Notification sent to user: $userId');
    } catch (e) {
      debugPrint('Error sending real notification: $e');
      // Fallback to simulation if something fails
      if (_supabase.auth.currentUser?.id == userId) {
        await _showLocalNotification(title: title, body: body, payload: data != null ? jsonEncode(data) : null);
      }
    }
  }

  // Send a notification specifically for measurement requests
  Future<void> sendMeasurementRequestNotification({
    String? userId,
    String? customerId, // Support both names to avoid lint errors
    required String tailorName,
    String? measurementId,
  }) async {
    final targetId = userId ?? customerId;
    if (targetId == null) return;

    await sendNotification(
      userId: targetId,
      title: 'Measurement Requested',
      body: '$tailorName has requested a measurement appointment.',
      data: {
        'type': 'measurement_request',
        'measurementId': measurementId,
      },
    );
  }

  // Send a notification specifically for new orders
  Future<void> sendNewOrderNotification({
    required String tailorId,
    required String customerName,
    required String orderId,
  }) async {
    await sendNotification(
      userId: tailorId,
      title: 'New Order Received',
      body: '$customerName has placed a new order.',
      data: {
        'type': 'new_order',
        'orderId': orderId,
      },
    );
  }

  // Send a notification specifically for new messages
  Future<void> sendMessageNotification({
    required String receiverId,
    required String senderName,
    required String content,
    String? orderId,
  }) async {
    await sendNotification(
      userId: receiverId,
      title: 'New Message from $senderName',
      body: content,
      data: {
        'type': 'new_message',
        'otherUserId': _supabase.auth.currentUser?.id,
        'otherUserName': senderName,
        'orderId': orderId,
      },
    );
  }

  // Send a notification specifically for measurement appointments
  Future<void> sendMeasurementNotification({
    required String receiverId,
    required String customerName,
    required String appointmentTime,
  }) async {
    await sendNotification(
      userId: receiverId,
      title: 'New Measurement Appointment',
      body: '$customerName has scheduled an appointment for $appointmentTime.',
      data: {
        'type': 'measurement_appointment',
        'customerName': customerName,
      },
    );
  }

  // Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        String? type = data['type'];
        _navigateFromNotification(type: type, data: data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Navigate based on notification type
  Future<void> _navigateFromNotification({
    required String? type,
    required Map<String, dynamic> data,
  }) async {
    if (_navigatorKey?.currentContext == null) return;

    final context = _navigatorKey!.currentContext!;

    switch (type) {
      case 'new_order':
      case 'order_update':
        final String? orderId = data['orderId'];
        if (orderId != null) {
          await _navigateToOrder(context, orderId);
        }
        break;
      case 'new_message':
        final String? otherUserId = data['otherUserId'];
        final String? otherUserName = data['otherUserName'];
        if (otherUserId != null && otherUserName != null) {
          _navigateToChat(
            context,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          );
        }
        break;
      case 'measurement_appointment':
        // Navigate to appointments/schedule if context is tailor
        break;
      case 'measurement_detail':
        // Navigate to measurement screen if needed
        break;
    }
  }

  Future<void> _navigateToOrder(BuildContext context, String orderId) async {
    try {
      final data = await _supabase.from('orders').select().eq('id', orderId).single();
      if (!context.mounted) return;
      final order = OrderModel.fromMap(data);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
      );
    } catch (e) {
      debugPrint('Error navigating to order: $e');
    }
  }

  void _navigateToChat(BuildContext context, {required String otherUserId, required String otherUserName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }

  // Real-time Listeners started here...
  void startRealtimeListeners(String userId) {
    // Clear existing listeners
    clearListeners();

    // 📩 Listen for New Messages
    final messageChannel = _supabase
        .channel('public:messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) async {
            debugPrint('NotificationService: New message received via Realtime');
            final data = payload.newRecord;
            // Fallback for missing sender_name column in DB
            final senderName = data['sender_name'] ?? 'Someone';
            await _showLocalNotification(
              title: 'New Message from $senderName',
              body: data['content'] ?? 'New message received',
              payload: jsonEncode({
                'type': 'new_message',
                'otherUserId': data['sender_id'],
                'otherUserName': senderName,
              }),
            );
          },
        )
        .subscribe((status, error) {
          debugPrint('NotificationService: Message Channel Status: $status, Error: $error');
        });
    _channels.add(messageChannel);

    // 🗓️ Listen for Measurements (Bi-directional)
    final measurementChannel = _supabase
        .channel('public:measurements')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'measurements',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tailor_id',
            value: userId,
          ),
          callback: (payload) async {
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'New Measurement Request',
              body: '${data['customer_name']} has sent measurement details.',
              payload: jsonEncode({
                'type': 'measurement_detail',
                'measurementId': data['id'],
              }),
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'measurements',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: userId,
          ),
          callback: (payload) async {
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'Measurement Updated',
              body: 'Tailor ${data['tailor_name']} has updated/accepted your measurements.',
              payload: jsonEncode({
                'type': 'measurement_detail',
                'measurementId': data['id'],
              }),
            );
          },
        )
        .subscribe((status, error) {
          debugPrint('NotificationService: Measurement Channel Status: $status, Error: $error');
        });
    _channels.add(measurementChannel);

    // 📦 Listen for New Orders (For Tailors)
    final orderChannel = _supabase
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tailor_id',
            value: userId,
          ),
          callback: (payload) async {
            debugPrint('NotificationService: New order received via Realtime');
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'New Order Received',
              body: '${data['customer_name']} has placed a new order.',
              payload: jsonEncode({
                'type': 'new_order',
                'orderId': data['id'],
              }),
            );
          },
        )
        .subscribe((status, error) {
          debugPrint('NotificationService: Order Channel Status: $status, Error: $error');
        });
    _channels.add(orderChannel);

    // 🗓️ Listen for Appointment Updates (Both New and Status Changes)
    final appointmentChannel = _supabase
        .channel('public:appointments')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert, // NEW appointments for Tailors
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tailor_id',
            value: userId,
          ),
          callback: (payload) async {
            debugPrint('NotificationService: New appointment request received via Realtime');
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'New Appointment Request',
              body: '${data['customer_name']} wants to book an appointment.',
              payload: jsonEncode({
                'type': 'new_appointment',
                'appointmentId': data['id'],
              }),
            );
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update, // STATUS updates for Customers
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: userId,
          ),
          callback: (payload) async {
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'Appointment Status Updated',
              body: 'Your appointment with ${data['tailor_name']} is now ${data['status']}.',
              payload: jsonEncode({
                'type': 'appointment_update',
                'appointmentId': data['id'],
              }),
            );
          },
        )
        .subscribe((status, error) {
          debugPrint('NotificationService: Appointment Channel Status: $status, Error: $error');
        });
    _channels.add(appointmentChannel);

    // 📦 Listen for Order Updates (For Customers)
    final orderUpdateChannel = _supabase
        .channel('public:order_updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: userId,
          ),
          callback: (payload) async {
            final data = payload.newRecord;
            await _showLocalNotification(
              title: 'Order Update',
              body: 'Your order status has been updated to ${data['status']}.',
              payload: jsonEncode({
                'type': 'order_update',
                'orderId': data['id'],
              }),
            );
          },
        )
        .subscribe((status, error) {
          debugPrint('NotificationService: OrderUpdate Channel Status: $status, Error: $error');
        });
    _channels.add(orderUpdateChannel);

    debugPrint('Real-time notification listeners started for user: $userId');
  }

  void clearListeners() {
    for (final channel in _channels) {
      _supabase.removeChannel(channel);
    }
    _channels.clear();
  }
}
