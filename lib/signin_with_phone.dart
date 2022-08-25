// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_signup/landing_page.dart';
import 'package:firebase_signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';

class SigninWithPhone extends StatefulWidget {
  static const routeName = 'SigninWithPhone';
  const SigninWithPhone({Key key}) : super(key: key);

  @override
  _SigninWithPhoneState createState() => _SigninWithPhoneState();
}

class _SigninWithPhoneState extends State<SigninWithPhone> {
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
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
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
              Navigator.pushNamed(context, LandingPage.routeName);
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
                      verificationId: verificationId,
                      smsCode: smsCode,
                    );
                    auth.signInWithCredential(_credential).then((result) {
                      if (result != null) {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, LandingPage.routeName);
                      }
                    }).catchError((e) {
                      print(e);
                    });
                  },
                ),
              ],
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print('AUTORETRIVAL SECTION');
          print(verificationId);
          print("Timout");
        },
        timeout: Duration(
          seconds: 45,
        ),
      );
    } catch (e) {}
    
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
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  ElevatedButton(
                    onPressed: _signInWithMobileNumber,
                    child: Text(
                      'Send OTP ',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
