import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_signup/home.dart';
import 'package:firebase_signup/landing_page.dart';
import 'package:firebase_signup/page/item_list_page.dart';
import 'package:firebase_signup/signin.dart';
import 'package:firebase_signup/signin_with_phone.dart';
import 'package:firebase_signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'account.dart';

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
      title: 'Flutter Demo 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
      routes: {
        Home.routeName: (ctx) => Home(),
        Signup.routeName: (ctx) => Signup(),
        Signin.routeName: (ctx) => Signin(),
        LandingPage.routeName: (ctx) => LandingPage()
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    getTokent();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    super.initState();
  }

  getTokent() async {
    String deviceToken = await FirebaseMessaging.instance.getToken();
    print('DEVICE TOKEN ' + deviceToken);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    print('NOTIFICATION TITLE ' + notification.title.toString());
    showModalBottomSheet(
      context: context,
      builder: ((context) {
        return Container(
          child: Column(
            children: [
              Text(notification.title),
              Text(
                notification.body,
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //body: Account(),
        body: ItemListPage()
        // body: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, snapshot) {
        //     print('PRINT AUTHSTATE DATA ');
        //     print(snapshot);
        //     print(snapshot.hasData);
        //     if (ConnectionState.waiting == snapshot.connectionState) {
        //       return Container(
        //         child: CircularProgressIndicator.adaptive(),
        //       );
        //     }

        //     if (snapshot.hasData) {
        //       return LandingPage();
        //     } else {
        //       return Signin();
        //     }
        //   },
        // ),
        );
  }
}
