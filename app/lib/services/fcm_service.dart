import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. MUST be a top-level function (outside the class) with @pragma
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeFCM({String? userId}) async {
    // 2. Fixed permission request parameters
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false, // Replaced invalid 'carryForward'
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not granted permission');
      return;
    }

    // 3. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Retrieve and save FCM Token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    if (token != null && userId != null) {
      await saveTokenToUser(userId, token);
    }

    // 5. Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (userId != null) {
        await saveTokenToUser(userId, newToken);
      }
    });

    // 6. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      // Here you can trigger local notifications if needed
    });

    // 7. Handle App Opened from Terminated / Background State
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.data}');
    });
  }

  /// Save user token to Firestore for targeted push notifications
  Future<void> saveTokenToUser(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }
}
