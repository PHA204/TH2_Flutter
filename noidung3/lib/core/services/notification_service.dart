// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission();
    
    // Get token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Save token to Firestore
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }
  
  void _handleMessage(RemoteMessage message) {
    print('Received: ${message.notification?.title}');
    // Show local notification
  }
  
  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }
}