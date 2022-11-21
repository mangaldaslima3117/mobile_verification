import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signup/account.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({Key key}) : super(key: key);

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vegetables',
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('vegetables').snapshots(),
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return Container(
              child: snapshot.data.docs.length > 0
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 0.02,
                        crossAxisSpacing: 0.02,
                      ),
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
                                  options: CarouselOptions(height: MediaQuery.of(context).size.height * 0.3,),
                                  items: new List<String>.from(snapshot
                                          .data.docs[index]['itemImageUrl'])
                                      .map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(i))),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              )
                              // Container(
                              //   height:
                              //       MediaQuery.of(context).size.height * 0.4,
                              //   width: MediaQuery.of(context).size.width * 0.3,
                              //   decoration: BoxDecoration(
                              //     image: DecorationImage(
                              //       image: NetworkImage(snapshot
                              //           .data.docs[index]['itemImageUrl']
                              //           .toString()),
                              //     ),
                              //   ),
                              // ),
                              ,
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
                      })
                  : Container(
                      child: Center(
                        child: Text(
                          'No item found',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
            );
          } else {
            return Container();
          }
        }),
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
