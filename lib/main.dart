import 'package:flutter/material.dart';
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('videoView', (viewId) {
      final video = VideoElement();
      List<dynamic> videoinputs = [];
      MediaDevices? m = window.navigator.mediaDevices;
      if (m == null) {
        return video;
      } else {
        m.enumerateDevices().then((devices) {
          videoinputs = devices.where((d) => d.kind == 'videoinput').toList();
        }).whenComplete(() {
          videoinputs.forEach((element) {
            print('camera: {element.label}');
          });
        });
      }

      video.autoplay = true;
      window.navigator.getUserMedia(video: {
        'width': {'min': 720, 'ideal': 1080, 'max': 1280},
      }, audio: true).then((stream) {
        video.srcObject = stream;
      });
      return video;
    });
    return MaterialApp(
      title: 'Flutter WebRTC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'WebRTC Sample for Flutter Web'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: HtmlElementView(viewType: 'videoView'),
    );
  }
}
