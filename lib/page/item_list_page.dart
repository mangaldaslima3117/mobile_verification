import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signup/new_item_page.dart';

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
          'Vegetable Shop',
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('vegetables').snapshots(),
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return LayoutBuilder(builder: (context, constraints) {
              return constraints.maxWidth < 600
                  ? Container(
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: ((context, index) {
                          return cartItemWidget(context, snapshot);
                        }),
                      ),
                    )
                  : Container(
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
                                return cartItemWidget(
                                    context, snapshot.data.docs[index]);
                              },
                            )
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
            });
          } else {
            return Container();
          }
        }),
      ),
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        //width: MediaQuery.of(context).size.width * 0.1,
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => NewItemPage()),
              ),
            );
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

  Card cartItemWidget(
    BuildContext context,
    var snapshot,
  ) {
    return Card(
      //color: Colors.amber[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      snapshot['itemImageUrl'][0],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Text('${snapshot['itemName']}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Price : \u{20B9}${snapshot['itemPrice']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit,
                    color: Colors.orange,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
