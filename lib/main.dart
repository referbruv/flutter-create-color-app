import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage('Color Creator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage(this.title);
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState(title);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _boundaryKey = GlobalKey();
  final String title;
  Color _color = Colors.blueGrey;
  _MyHomePageState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded),
            onPressed: () async {
              print('save pressed, now should capture the screen.');
              var path = await _captureImage();
              Fluttertoast.showToast(
                  msg: 'Image saved at $path', toastLength: Toast.LENGTH_LONG);
            },
          )
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: _color),
                padding: EdgeInsets.all(50.0),
                margin: EdgeInsets.all(50.0),
                child: Text(
                  'RGB(${_color.red}, ${_color.green}, ${_color.blue})',
                  style: TextStyle(fontSize: 25.0),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh_rounded),
        onPressed: () {
          print('refresh tapped, should change color');
          setState(() {
            _color = Colors.red;
          });
        },
      ),
    );
  }

  Future<String> _captureImage() async {
    RenderRepaintBoundary boundary =
        _boundaryKey.currentContext.findRenderObject();
    var image = await boundary.toImage();

    var directory;
    if (Platform.isAndroid) {
      // this method is not supported in iOS
      // so fallback to the regular documents directory
      // get the directory to write the file
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // prepare the file path
    var filePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

    // extract bytes from the image
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    // openwrite a File with the specified path
    File imgFile = new File(filePath);

    // write the image bytes to the file
    imgFile.writeAsBytes(pngBytes);

    // return the created file
    return filePath;
  }
}
