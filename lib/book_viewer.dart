import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookViewer extends StatelessWidget {
  final String bookUrl;
  final String bookName;
  const BookViewer({Key key, this.bookUrl, this.bookName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bookName)),
      body: Container(
        child: SfPdfViewer.network(
          bookUrl,
        ),
      ),
    );
  }
}
