import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:provider/provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/config/navigation_service.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class PushNotificationsManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging();

  Future<void> init(BuildContext context) async {
    String token = await _firebaseMessaging.getToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationToken', token);

    FirebaseMessaging.onMessageOpenedApp.listen(context, _handleMessage);

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;

    //   // If `onMessage` is triggered with a notification, construct our own
    //   // local notification to show to users using the created channel.
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             icon: android?.smallIcon,
    //             // other properties...
    //           ),
    //         ));
    //   }
    // });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) async {
    if (message.data['type'] == 'chat') {
      var deviceIndex = Provider.of<DevicesProvider>(context, listen: false)
          .findDevice(message.data['deviceId']);

      if (deviceIndex != null) {
        await Navigator.of(context).pushNamed(
          routes.SetupActiveRoute,
          arguments: {'deviceIndex': deviceIndex},
        );
      }
    }
  }
}
