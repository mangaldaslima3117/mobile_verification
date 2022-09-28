import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_signup/main.dart';
import 'package:firebase_signup/signin.dart';
import 'package:firebase_signup/signin_with_phone.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LandingPage extends StatelessWidget {
  static const routeName = 'SigninWithPhone';
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();

              await FirebaseAuth.instance.signOut().then((value) {
                print('Is signed in ' + googleSignIn.isSignedIn().toString());
                //await googleSignIn.disconnect();

                print('INSDIE THE SIGNOUT');
                Navigator.pushReplacementNamed(
                  context,
                  Signin.routeName,
                );
              });
            },
            icon: Icon(
              Icons.logout_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: 150,
        child: ListTile(
          leading: Container(
            child: Image(
              image: AssetImage(
                'assets/lima_tech.png',
              ),
            ),
          ),
          title: Text(
            'Lima Tech',
          ),
          subtitle: Text(
            'Subscribed 316',
          ),
          trailing: Container(
            width: 150,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'SUBSCRIBED',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.subscriptions,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
