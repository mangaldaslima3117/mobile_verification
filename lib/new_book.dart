import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_signup/page/book_list_mobile.dart';
import 'package:firebase_signup/page/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;
import 'package:http/http.dart' as http;

class NewBook extends StatefulWidget {
  @override
  State<NewBook> createState() => _NewBookState();
}

class _NewBookState extends State<NewBook> {
  String defaultImageUrl =
      'https://cdn.pixabay.com/photo/2016/03/23/15/00/ice-cream-1274894_1280.jpg';
  String selctFile = '';
  String bookName = '';
  XFile file;
  Uint8List selectedBookImageInBytes;
  Uint8List selectedBookPdfInBytes;
  List<Uint8List> pickedImagesInBytes = [];
  List<String> imageUrls = [];
  int imageCounts = 0;
  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();
  TextEditingController _deviceTokenController = TextEditingController();
  bool isItemSaved = false;

  @override
  void initState() {
    //deleteVegetable();
    super.initState();
  }

  @override
  void dispose() {
    _bookNameController.dispose();
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

  _selectFile(bool isPickingImage) async {
    FilePickerResult fileResult =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (fileResult != null) {
      print(fileResult);

      File file = File(fileResult.files.single.path);
      setState(() {
        if (isPickingImage) {
          selctFile = fileResult.files.first.name;
          selectedBookImageInBytes = file.readAsBytesSync();
        } else {
          bookName = fileResult.files.first.name;
          selectedBookPdfInBytes = file.readAsBytesSync();
        }
      });
    }
    print('LENGTH OF SELECTED IMAGE ${selectedBookImageInBytes.length}');
  }

  Future<String> _uploadFile(Uint8List fileToUpload, bool isImageFile) async {
    String imageUrl = '';
    try {
      firabase_storage.UploadTask uploadTask;

      firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
          .ref()
          .child('books')
          .child('/' + (isImageFile ? selctFile : bookName));

      final metadata = firabase_storage.SettableMetadata(
          contentType: isImageFile ? 'image/jpeg' : 'application/pdf');

      //uploadTask = ref.putFile(File(file.path));
      uploadTask = ref.putData(fileToUpload, metadata);

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
    String imageUrl = await _uploadFile(selectedBookImageInBytes, true);
    String pdfUrl = await _uploadFile(selectedBookPdfInBytes, false);
    //await _uploadMultipleFiles(_bookNameController.text);
    //print('Uploaded Image URL ' + imageUrls.length.toString());
    await FirebaseFirestore.instance.collection('books').add({
      'bookName': _bookNameController.text,
      'authorName': _itemPriceController.text,
      'bookCoverImageUrl': imageUrl,
      'bookPdfUrl': pdfUrl,
      'createdOn': DateTime.now().toIso8601String(),
    }).then((value) {
      sendPushMessage();
      setState(() {
        isItemSaved = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BookListMobile()),
        (Route<dynamic> route) => false,
      );
    });
  }

  String constructFCMPayload(String token) {
    return jsonEncode({
      'to': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
      },
      'notification': {
        'title':
            'Your item  ${_bookNameController.text} is added successfully !',
        'body': 'Please subscribe, like and share this tutorial !',
      },
    });
  }

  Future<void> sendPushMessage() async {
    if (_deviceTokenController.text == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      String serverKey =
          "AAAA0RJf2UE:APA91bE_M-axKmqqoV5EinizvWP4T9bOkmCXAwU8JPFCEQsVCZXBdgsX2Nq_coDtvo49ULywfLtzorKS0TlB-1LxNQhFZRBrbk6hcoD0fgHy-i3ed0ehx7yDaHxYLzjXAt7vO2XDMIBD";
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey'
        },
        body: constructFCMPayload(_deviceTokenController.text),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Book',
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
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.5,
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
                      : Image.memory(selectedBookImageInBytes)

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
                    _selectFile(true); //set to false to pick pdf files
                  },
                  icon: const Icon(
                    Icons.camera,
                  ),
                  label: const Text(
                    'Pick Book Cover Image',
                    style: TextStyle(),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.orange,
                    ),
                  ),
                  onPressed: () {
                    //_showPicker(context);
                    _selectFile(false); //set to false to pick pdf files
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: const Text(
                    'Pick Book File',
                    style: TextStyle(),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Text('Book File Name : ${bookName}'),
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
                width: MediaQuery.of(context).size.width * 0.8,
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
                    labelText: 'Book Name',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  controller: _bookNameController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.8,
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
                    labelText: 'Author Name',
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.3,
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
