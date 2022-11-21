import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

import '../account.dart';

class ItemListMobile extends StatefulWidget {
  const ItemListMobile({Key key}) : super(key: key);

  @override
  State<ItemListMobile> createState() => _ItemListMobileState();
}

class _ItemListMobileState extends State<ItemListMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('vegetables').snapshots(),
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
                            Container(
                              child: CarouselSlider(
                                options: CarouselOptions(height: 400.0),
                                items: [1, 2, 3, 4, 5].map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration:
                                            BoxDecoration(color: Colors.amber),
                                        child: Text(
                                          'text $i',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            // Container(
                            //   height: MediaQuery.of(context).size.height * 0.4,
                            //   width: MediaQuery.of(context).size.width * 0.3,
                            //   decoration: BoxDecoration(
                            //     image: DecorationImage(
                            //       image: NetworkImage(snapshot
                            //           .data.docs[index]['itemImageUrl']
                            //           .toString()),
                            //     ),
                            //   ),
                            // ),
                            Container(
                              child: Text(
                                  '${snapshot.data.docs[index]['itemName']}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Price : \u{20B9}${snapshot.data.docs[index]['itemPrice']}',
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
        width: MediaQuery.of(context).size.width * 0.1,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(
            25,
          ),
          // border: Border.all(
          //   width: 1,
          //   //color: Colors.black,
          // ),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: ((context) => Account())));
          },
          child: Text(
            'New Item',
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
