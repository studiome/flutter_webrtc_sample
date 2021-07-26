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
  MediaDeviceInfo? selectedDevice;
  List<dynamic> videoInputs = [];

  @override
  void initState() {
    super.initState();
    MediaDevices? m = window.navigator.mediaDevices;
    if (m == null) {
      return;
    } else {
      m.enumerateDevices().then((devices) {
        videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
      }).whenComplete(() {
        setState(() {
          selectedDevice = videoInputs[0];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('videoView', (viewId) {
      final video = VideoElement();
      video.autoplay = true;
      if (selectedDevice == null) return video;
      window.navigator.getUserMedia(video: {
        'deviceId': selectedDevice!.deviceId,
        'width': {'min': 720, 'ideal': 1080, 'max': 1280},
      }, audio: false).then((stream) {
        video.srcObject = stream;
      });
      return video;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          DropdownButton<MediaDeviceInfo>(
            value: selectedDevice,
            items: videoInputs.map<DropdownMenuItem<MediaDeviceInfo>>((val) {
              return DropdownMenuItem<MediaDeviceInfo>(
                value: val,
                child: Text(val.label != null ? val.label! : 'video'),
              );
            }).toList(),
            onChanged: (MediaDeviceInfo? d) {
              setState(() {
                if (d != null) {
                  selectedDevice = d;
                }
              });
            },
          ),
          HtmlElementView(viewType: 'videoView'),
        ],
      ),
    );
  }
}
