import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_signup/page/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;

class Account extends StatefulWidget {
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String defaultImageUrl =
      'https://cdn.pixabay.com/photo/2016/03/23/15/00/ice-cream-1274894_1280.jpg';
  String selctFile = '';
  XFile file;
  Uint8List selectedImageInBytes;
  List<Uint8List> pickedImagesInBytes = [];
  List<String> imageUrls = [];
  int imageCounts = 0;
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();
  bool isItemSaved = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  //This modal shows image selection either from gallery or camera
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      //backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                    ),
                    title: const Text(
                      'Gallery',
                      style: TextStyle(),
                    ),
                    onTap: () {
                      _selectFile(true);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(),
                  ),
                  onTap: () {
                    _selectFile(false);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _selectFile(bool imageFrom) async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (fileResult != null) {
      selctFile = fileResult.files.first.name;
      fileResult.files.forEach((element) {
        setState(() {
          pickedImagesInBytes.add(element.bytes);
          //selectedImageInBytes = fileResult.files.first.bytes;
          imageCounts += 1;
        });
      });
    }
    print(selctFile);
  }

  Future<String> _uploadFile() async {
    String imageUrl = '';
    try {
      firabase_storage.UploadTask uploadTask;

      firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
          .ref()
          .child('product')
          .child('/' + selctFile);

      final metadata =
          firabase_storage.SettableMetadata(contentType: 'image/jpeg');

      //uploadTask = ref.putFile(File(file.path));
      uploadTask = ref.putData(selectedImageInBytes, metadata);

      await uploadTask.whenComplete(() => null);
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    return imageUrl;
  }

  Future<String> _uploadMultipleFiles(String itemName) async {
    String imageUrl = '';
    try {
      for (var i = 0; i < imageCounts; i++) {
        firabase_storage.UploadTask uploadTask;

        firabase_storage.Reference ref = firabase_storage
            .FirebaseStorage.instance
            .ref()
            .child('product')
            .child('/' + itemName + '_' + i.toString());

        final metadata =
            firabase_storage.SettableMetadata(contentType: 'image/jpeg');

        //uploadTask = ref.putFile(File(file.path));
        uploadTask = ref.putData(pickedImagesInBytes[i], metadata);

        await uploadTask.whenComplete(() => null);
        imageUrl = await ref.getDownloadURL();
        setState(() {
          imageUrls.add(imageUrl);
        });
      }
    } catch (e) {
      print(e);
    }
    return imageUrl;
  }

  saveItem() async {
    setState(() {
      isItemSaved = true;
    });
    //String imageUrl = await _uploadFile();
    await _uploadMultipleFiles(_itemNameController.text);
    print('Uploaded Image URL ' + imageUrls.length.toString());
    await FirebaseFirestore.instance.collection('vegetables').add({
      'itemName': _itemNameController.text,
      'itemPrice': _itemPriceController.text,
      'itemImageUrl': imageUrls,
      'createdOn': DateTime.now().toIso8601String(),
    }).then((value) {
      setState(() {
        isItemSaved = false;
      });
      Navigator.of(context)
          .push(MaterialPageRoute(builder: ((context) => ItemListPage())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vegetable Seller',
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: selctFile.isEmpty
                      ? Image.network(
                          defaultImageUrl,
                          fit: BoxFit.cover,
                        )
                      // Image.asset('assets/create_menu_default.png')
                      : CarouselSlider(
                          options: CarouselOptions(height: 400.0),
                          items: pickedImagesInBytes.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration:
                                      BoxDecoration(color: Colors.amber),
                                  child: Image.memory(i),
                                );
                              },
                            );
                          }).toList(),
                        )
                  //Image.memory(selectedImageInBytes)

                  // Image.file(
                  //     File(file.path),
                  //     fit: BoxFit.fill,
                  //   ),
                  ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //_showPicker(context);
                    _selectFile(true);
                  },
                  icon: const Icon(
                    Icons.camera,
                  ),
                  label: const Text(
                    'Pick Image',
                    style: TextStyle(),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              if (isItemSaved)
                Container(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    labelText: 'Item Name',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  controller: _itemNameController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    labelText: 'Item Price',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  controller: _itemPriceController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.08,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.green,
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
            saveItem();
          },
          child: Text(
            'Save',
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
