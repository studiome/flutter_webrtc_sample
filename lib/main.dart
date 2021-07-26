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
  List<MediaDeviceInfo> videoInputs = [];

  @override
  void initState() {
    super.initState();
    MediaDevices? m = window.navigator.mediaDevices;
    if (m == null) {
      return;
    } else {
      m.enumerateDevices().then((devices) {
        devices.forEach((element) {
          if (element.kind == 'videoinput') {
            videoInputs.add(element as MediaDeviceInfo);
          }
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
      if (selectedDevice == null) {
        window.navigator.getUserMedia(video: {
          'width': {'min': 720, 'ideal': 1080, 'max': 1280},
        }, audio: false).then((stream) {
          video.srcObject = stream;
        });
      } else {
        window.navigator.getUserMedia(video: {
          'deviceId': selectedDevice!.deviceId,
          'width': {'min': 720, 'ideal': 1080, 'max': 1280},
        }, audio: false).then((stream) {
          video.srcObject = stream;
        });
      }
      return video;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          DropdownButton<MediaDeviceInfo>(
            hint: Text("Select Video Device"),
            isExpanded: true,
            value: selectedDevice,
            items: videoInputs.map((val) {
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
