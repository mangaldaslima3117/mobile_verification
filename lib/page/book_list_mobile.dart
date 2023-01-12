import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signup/book_viewer.dart';
import 'package:firebase_signup/new_book.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

import '../account.dart';

class BookListMobile extends StatefulWidget {
  static const routeName = 'booklist';
  const BookListMobile({Key key}) : super(key: key);

  @override
  State<BookListMobile> createState() => _BookListMobileState();
}

class _BookListMobileState extends State<BookListMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Books',
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('books').snapshots(),
          builder: ((context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return Container(
                child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        //color: Colors.amber[200],
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) => BookViewer(
                                          bookUrl: snapshot.data.docs[index]
                                              ['bookPdfUrl'],
                                          bookName: snapshot.data.docs[index]
                                              ['bookName'],
                                        )),
                                  ),
                                );
                              },
                              child: Container(
                                child: Image.network(
                                  snapshot.data.docs[index]
                                      ['bookCoverImageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                child: Text(
                                  '${snapshot.data.docs[index]['bookName']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Author : ${snapshot.data.docs[index]['authorName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )),
                      );
                    }),
              );
            } else {
              return Container();
            }
          }),
        ),
      ),
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.3,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(
            25,
          ),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: ((context) => NewBook())));
          },
          child: Text(
            'New Book',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
