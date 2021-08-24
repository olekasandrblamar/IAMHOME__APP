import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:provider/provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/config/navigation_service.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class PushNotificationsManager {
  final context;
  PushNotificationsManager(context);

  PushNotificationsManager._(context);

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      // _firebaseMessaging.requestNotificationPermissions();

      // _firebaseMessaging.configure(
      //   onMessage: (Map<String, dynamic> message) async {
      //     print("onMessage: $message");
      //     // _handleNotification(message);
      //   },
      //   onLaunch: (Map<String, dynamic> message) async {
      //     print("onLaunch: $message");
      //     // _navigateToItemDetail(message);
      //   },
      //   onResume: (Map<String, dynamic> message) async {
      //     print("onResume: $message");
      //     // _navigateToItemDetail(message);
      //   },
      // );

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notificationToken', token);

      // print("FirebaseMessaging token: $token");

      // FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      _initialized = true;
    }
  }

  void _handleMessage(RemoteMessage message) async {
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

    // if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(
    //     context,
    //     '/chat',
    //     arguments: ChatArguments(message),
    //   );
    // }
  }
}
