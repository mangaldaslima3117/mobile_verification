import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_signup/home.dart';
import 'package:firebase_signup/landing_page.dart';
import 'package:firebase_signup/signin.dart';
import 'package:firebase_signup/signin_with_phone.dart';
import 'package:firebase_signup/signup.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SigninWithPhone(),
      routes: {
        Home.routeName: (ctx) => Home(),
        Signup.routeName: (ctx) => Signup(),
        Signin.routeName: (ctx) => Signin(),
        LandingPage.routeName: (ctx) => LandingPage()
      },
    );
  }
}
