import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_signup/page/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBREdiDdOJNdvJDIRYrLYraWNVlalSvlJs',
      appId: '1:897956436289:web:a88b4ac73fb4baced4a9c0',
      messagingSenderId: '897956436289',
      projectId: 'flutter-tutorial-843d7',
      storageBucket: "flutter-tutorial-843d7.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const String routeName = 'my-app';
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final googleSignIn = GoogleSignIn();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItemListPage(),
    );
  }
}