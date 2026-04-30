import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_notification.dart';
import '../main.dart';

class NotifincationInFirebase {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  Future<void> init(BuildContext context) async {

    const androidSettings =
    AndroidInitializationSettings('@drawable/ic_launcher');

    const initializationSetting = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSetting,

      onDidReceiveNotificationResponse: (NotificationResponse response) {

        if(response.payload != null){
          final data = jsonDecode(response.payload!);
          _nevigateTopage(data);
        }
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.subscribeToTopic('all_users');

    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _nevigateTopage(message.data);
    });

    RemoteMessage? initalmessage = await messaging.getInitialMessage();
    if (initalmessage != null){
      _nevigateTopage(initalmessage.data);
    }



  }

  Future<void> showNotification(RemoteMessage message) async {

    final payload = jsonEncode({
      'type': message.data['type'] ?? '',
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'image': message.data['image'] ?? '',
    });


    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      color: const Color(0xFF0D6186),

      styleInformation: message.data['image'] != null
          ? BigPictureStyleInformation(
        FilePathAndroidBitmap(message.data['image']),
        contentTitle: message.notification?.title,
        summaryText: message.notification?.body,
      )
          : null,
    );


    await _flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: NotificationDetails(android: androidNotificationDetails),
      payload: payload
    );

    await saveNotificaton(message);

  }

  void _nevigateTopage(Map<String, dynamic> data){

    if (data['type'] == 'msj') {

      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => FirebaseNotification(
            title: data['title'] ?? '',
            body: data['body'] ?? '',
            image: data['image'] ?? '',
          )
        ));

    }

  }

  Future<void> saveNotificaton(RemoteMessage message)async{
    final prefs = await SharedPreferences.getInstance();

    List<String> notifications = prefs.getStringList('mydatabase') ?? [];

    final newNotification = jsonEncode({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'type': message.data['type'] ?? '',
      'image': message.data['image'] ?? '',
      'time': DateTime.now().toString(),
    });

    notifications.add(newNotification);
    await prefs.setStringList('mydatabase', notifications);


  }

}