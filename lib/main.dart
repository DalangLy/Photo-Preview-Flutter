import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Preview'),
      ),
      body: GestureDetector(
        child: Hero(
          tag: 'imageHero',
          child: _image == null
              ? Text("No Image Selected!")
              : Image.file(
                  _image,
                  fit: BoxFit.contain,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
        ),
        onTap: () {
          SystemChrome.setEnabledSystemUIOverlays(
              []); //set full screen (remove status bar and bottom buttons)
          Wakelock.enable(); //make screen alway on
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return FullScreenView(_image);
          }));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: "Open Image",
        child: Icon(Icons.image),
      ),
    );
  }
}

class FullScreenView extends StatelessWidget {
  File image;
  FullScreenView(var image) {
    this.image = image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
              tag: 'imageHero',
              child: image == null
                  ? Text("No Image Selected!")
                  : PhotoView(
                      imageProvider: FileImage(image),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      enableRotation: true,
                      backgroundDecoration:
                          BoxDecoration(color: Theme.of(context).canvasColor),
                      loadingChild: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )),
        ),
        onTap: () {
          Navigator.pop(context);
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          Wakelock.disable(); //make screen to auto sleep
        },
      ),
    );
  }
}
