import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signup/signin.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  static const routeName = 'home';
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  showModalBox(String docId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  controller: _nameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
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
                SizedBox(
                  height: 15,
                ),
                TextFormField(
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
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .update({
                      'name': _nameController.text,
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    }).then((value) {
                      _nameController.text = '';
                      _emailController.text = '';
                      _passwordController.text = '';
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text(
                    'Update ',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users List',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final googleSignIn = GoogleSignIn();
              final user = await googleSignIn.signOut();
              if (user == null) {
                Navigator.pushNamed(context, Signin.routeName);
              }
            },
            icon: Icon(
              Icons.logout_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 160,
                          child: Text(snapshot.data.docs[index]['name']),
                        ),
                        Container(
                          width: 140,
                          child: Text(snapshot.data.docs[index]['email']),
                        ),
                        IconButton(
                          onPressed: () {
                            _nameController.text =
                                snapshot.data.docs[index]['name'];
                            _emailController.text =
                                snapshot.data.docs[index]['email'];
                            _passwordController.text =
                                snapshot.data.docs[index]['password'];
                            showModalBox(snapshot.data.docs[index].id);
                          },
                          icon: Icon(
                            Icons.edit,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
