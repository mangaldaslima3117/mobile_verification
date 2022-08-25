// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';

class Signin extends StatefulWidget {
  static const routeName = 'signin';
  const Signin({Key key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _mobileController = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String smsCode = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  _Signin() async {
    //var valid = _formKey.currentState.validate();
    User user;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      user = userCredential.user;

      if (user != null) {
        Navigator.pushNamed(context, Home.routeName);
      }
    } catch (e) {}
    // if (!valid) {
    //   return;
    // } else {}
  }

  _signInWithMobileNumber() async {
    UserCredential _credential;
    //var valid = _formKey.currentState.validate();
    User user;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91' + _mobileController.text.trim(),
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          print('AUTH CREDENTIAL');
          print(authCredential);
          await _auth.signInWithCredential(authCredential).then((value) {
            if (value != null) {
              print(value);
            }
          });
        },
        verificationFailed: ((error) {
          print(error);
        }),
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show dialog to take input from the user
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text("Enter OTP"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text("Done"),
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    smsCode = _codeController.text.trim();
                    PhoneAuthCredential _credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsCode);
                    // auth.signInWithCredential(_credential).then((result) {
                    //   if (result != null) {
                    //     Navigator.of(context).pop();
                    //     Navigator.pushNamed(context, Home.routeName);
                    //   }
                    // }).catchError((e) {
                    //   print(e);
                    // });
                  },
                ),
              ],
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        },
      );

      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //     email: _emailController.text, password: _passwordController.text);
      // user = userCredential.user;

      // if (user != null) {
      //   Navigator.pushNamed(context, Home.routeName);
      // }
    } catch (e) {}
    // if (!valid) {
    //   return;
    // } else {}
  }

  _signinWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final user = await googleSignIn.signIn();

      if (user != null) {
        print('User name ' + user.displayName);
        if (user != null) {
          Navigator.pushNamed(context, Home.routeName);
        }
      } else {
        print('Sign in failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Sign in',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                    ),
                    controller: _mobileController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter mobile";
                      }
                      if (!value.contains('@')) {
                        return "Invalid mobile number";
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _signInWithMobileNumber,
                  child: Text(
                    'Send OTP ',
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                ),
                Center(
                  child: Text('or'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    controller: _emailController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter email";
                      }
                      if (!value.contains('@')) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter password";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _Signin,
                  child: Text(
                    'Signin ',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text("Don't have an account ? "),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Signup.routeName);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )
                  ],
                ),
                Center(
                  child: Text('or'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _signinWithGoogle,
                  child: Text(
                    'Sign in with Google',
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
