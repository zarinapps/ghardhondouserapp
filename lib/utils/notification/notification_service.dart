import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final AwesomeNotifications _awesomeNotifications =
      AwesomeNotifications();

  // Initialize notification services
  static Future<void> init(BuildContext context) async {
    await _requestPermissions();
    await _initializeAwesomeNotifications();
    _registerFirebaseListeners(context);
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    await _messaging.requestPermission();

    // Request Awesome Notifications permissions
    final isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications(
        channelKey: Constant.notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
        ],
      );
    }
  }

  // Static method for background message handling
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    // Initialize Firebase if needed
    await Firebase.initializeApp();

    // Prevent duplicate notifications in background state
    if (message.data['type'] == 'chat') {
      // Generate a unique ID based on message content
      final uniqueId = _generateUniqueNotificationId(message);

      // Check if this notification has already been shown
      final isDuplicate = await _checkDuplicateNotification(uniqueId);

      if (!isDuplicate) {}
    }
  }

  // Generate a unique ID for the notification
  static int _generateUniqueNotificationId(RemoteMessage message) {
    // Create a hash based on key message details to identify duplicates
    return message.data['sender_id'].hashCode ^
        message.data['property_id'].hashCode ^
        message.data['message_id'].hashCode;
  }

  // Check if notification is a duplicate
  static Future<bool> _checkDuplicateNotification(int uniqueId) async {
    // Implement a simple duplicate check
    // You might want to use a more robust solution like SharedPreferences or a local database
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationTime = prefs.getInt('last_notification_$uniqueId');

    if (lastNotificationTime == null) {
      // First time seeing this notification
      await prefs.setInt(
          'last_notification_$uniqueId', DateTime.now().millisecondsSinceEpoch);
      return false;
    }

    // Prevent duplicate within 5 seconds
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime - lastNotificationTime < 5000;
  }

  // Initialize Awesome Notifications
  static Future<void> _initializeAwesomeNotifications() async {
    await _awesomeNotifications.initialize(
      null,
      [
        NotificationChannel(
          channelKey: Constant.notificationChannel,
          channelName: 'General Notifications',
          channelDescription: 'Notification channel for app',
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'Chat Notification',
          channelName: 'Chat Notifications',
          channelDescription: 'Notifications for chat messages',
          importance: NotificationImportance.High,
        ),
      ],
    );

    // Set notification listeners
    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _handleNotificationTap,
    );
  }

  // Register Firebase message listeners
  static void _registerFirebaseListeners(BuildContext context) {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleIncomingMessage);

    // Background/Terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

    // Initial message when app is launched from terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationNavigation(message);
      }
    });
  }

  // Handle notification navigation for background/terminated states
  static void _handleNotificationNavigation(RemoteMessage message) {
    final payload = message.data;

    if (payload['type'] == 'chat') {
      _navigateToChatScreen(payload);
    } else {
      _navigateToPropertyDetails(payload);
    }
  }

  // Handle incoming messages
  static void _handleIncomingMessage(
    RemoteMessage message,
  ) {
    final isChat = message.data['type'] == 'chat';

    if (isChat) {
      _createChatNotification(message);
    } else {
      _createGeneralNotification(message);
    }
  }

  // Create chat notification
  static Future<void> _createChatNotification(RemoteMessage message) async {
    final chatId = int.parse(message.data['sender_id']?.toString() ?? '0') +
        int.parse(message.data['property_id']?.toString() ?? '0');

    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: chatId,
        channelKey: 'Chat Notification',
        title: message.data['title']?.toString() ?? '',
        body: message.data['body']?.toString() ?? '',
        payload: message.data.cast<String, String>(),
        notificationLayout: NotificationLayout.MessagingGroup,
      ),
    );
  }

  // Create general notification
  static Future<void> _createGeneralNotification(RemoteMessage message) async {
    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: Random().nextInt(5000),
        channelKey: Constant.notificationChannel,
        title: message.data['title']?.toString() ?? '',
        body: message.data['body']?.toString() ?? '',
        payload: message.data.cast<String, String>(),
      ),
    );
  }

  // Static method to handle notification tap
  @pragma('vm:entry-point')
  static Future<void> _handleNotificationTap(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload;

    if (payload?['type'] == 'chat') {
      _navigateToChatScreen(payload);
    } else {
      await _navigateToPropertyDetails(payload);
    }
  }

  // Navigate to chat screen
  static void _navigateToChatScreen(Map<String, dynamic>? payload) {
    if (payload == null) return;

    Navigator.push(
      Constant.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => LoadChatMessagesCubit()),
            BlocProvider(create: (context) => DeleteMessageCubit()),
          ],
          child: ChatScreen(
            profilePicture: payload['user_profile']?.toString() ?? '',
            userName: payload['username']?.toString() ?? '',
            propertyImage: payload['property_title_image']?.toString() ?? '',
            proeprtyTitle: payload['title']?.toString() ?? '',
            userId: payload['sender_id']?.toString() ?? '',
            propertyId: payload['property_id']?.toString() ?? '',
            isBlockedByMe: payload['is_blocked_by_me'] == 'true',
            isBlockedByUser: payload['is_blocked_by_user'] == 'true',
          ),
        ),
      ),
    );
  }

  // Navigate to property details
  static Future<void> _navigateToPropertyDetails(
    Map<String, dynamic>? payload,
  ) async {
    if (payload == null) return;

    final id = payload['id']?.toString() ?? '';
    final isMyProperty = payload['added_by'] == HiveUtils.getUserId();

    final property = await PropertyRepository().fetchPropertyFromPropertyId(
      id: int.parse(id),
      isMyProperty: isMyProperty,
    );

    HelperUtils.goToNextPage(
      Routes.propertyDetails,
      Constant.navigatorKey.currentContext!,
      false,
      args: {
        'propertyData': property,
        'fromMyProperty': false,
      },
    );
  }

  // Update FCM token
  Future<void> updateFCMToken() async {
    // Implement token update logic here
  }

  // Dispose listeners
  void dispose() {
    _awesomeNotifications.dispose();
  }
}
