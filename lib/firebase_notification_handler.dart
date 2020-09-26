import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Partial/Sender.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {

  print("received from background");
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }
  if (message.containsKey('notification')) {
    Map<String, dynamic> note = message['notification'];
    //  sendLocal(note);

  }
  return Future.value();
  // Or do other work.
}


class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  String token;


  Future<String> setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    try{

      return fireBaseCloudMessagingListeners();
    } catch(e){
      print("$e");
    }
    return null;
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();



  void sendToToken()async{

   // final String token = this.token ?? await _firebaseMessaging.getToken();
    //this.token = token;

    Clipboard.setData(ClipboardData(text: token));
    final String serverToken = 'AAAAg-FJSfc:APA91bHr7OgmwmcP401YFBJZK_hkeeSO2qbMHXZaJa7Zup9U8dZ8XQqlFnF_z5q5fa9wskRu4PNiK8IMn0lYBjxJgi8srcafC1Mc-p2GU6T8v5kAQKvjwZoDJ_R0PVCvfroX09muIwln';

//    Dio().post(
//      'https://fcm.googleapis.com/fcm/send',
//      options: Options(headers: <String, String>{
//        'Content-Type': 'application/json',
//        'Authorization': 'key=$serverToken',
//      }),
//      data: <String, dynamic>{
//        'notification': <String, dynamic>{
//          'body': 'this is a body from app',
//          'title': 'this is a title from app'
//        },
//        'priority': 'high',
//        'data': <String, dynamic>{
//          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//          'id': '1',
//          'status': 'done'
//        },
//        'to': token,
//      },
//    ).then((f){print(f.data.toString());});
  }

  Future<String> fireBaseCloudMessagingListeners(){
    if (Platform.isIOS) iOS_Permission();

    sendToToken();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {


        print(message);
        print("digest");
        if( message['notification'] != null) {
          //Map<String, dynamic> note = message['notification'];
          Sender.scheduleNotification(title: message['notification']['title'],text: message['notification']['body']);
        }
        if (message.containsKey('notification')) {
        }

      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        if (message.containsKey('notification')) {
        Map<String, dynamic> note = message['notification'];
      }
        Sender.scheduleNotification(title: "On resume");
      },
      onLaunch: (Map<String, dynamic> message) async {
        Sender.scheduleNotification(title: "On launch");
      },
    );

    return _firebaseMessaging.getToken();
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}