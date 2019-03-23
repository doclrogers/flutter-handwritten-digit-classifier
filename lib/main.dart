import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'classify.dart';
import 'camera.dart';

void main() => runApp(HandwrittenDigitClassifierApp());

class HandwrittenDigitClassifierApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handwritten Digit Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Handwritten Digit Classifier'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _imageFiles = new List<String>();

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: _classifyImages(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('Please wait: Classification of images in progress...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: futureBuilder,
      floatingActionButton: FloatingActionButton(
        onPressed: _launchCamera,
        tooltip: 'Take a picture',
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void _launchCamera() async {
    cameras = await availableCameras();
    final String image = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraApp()),
    );

    setState(() {
      _imageFiles.add(image);
    });
  }

  Future<List> _classifyImages() async {
    var values = new List<MnistClassifierResult>();

    if (_imageFiles.length > 0) {
      for (String img in _imageFiles) {
        if (img != null) values.add(await classifyImage(img));
      }
    }

    return values;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<MnistClassifierResult> values = snapshot.data;

    if (snapshot.hasData && values.length > 0) {
      return ListView.builder(
          itemBuilder: (context, i) {
            if (i < values.length) {
              return _buildRow(values[i]);
            }
          });
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Instructions', style: TextStyle(decoration: TextDecoration.underline)),
            Text('1. Write a number on a piece of paper.'),
            Text('2. Press the camera button to launch the camera.'),
            Text('3. Zoom in closely and center the number on the screen.'),
            Text('4. Take the picture.'),
          ],
        ),
      );
    }
  }

  Widget _buildRow(MnistClassifierResult res) {
    return ListTile(
      leading: new Image.file(new File(res.fileName), height: 28, fit: BoxFit.scaleDown),
      title: Text(res.label),
      subtitle: Text('Confidence: ' + res.confidence.toString()),
      trailing: Text(res.index.toString()),
    );
  }
}
