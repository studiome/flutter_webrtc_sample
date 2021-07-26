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

  Future<List<dynamic>> getDevices() async {
    List<dynamic> v = [];
    MediaDevices? m = window.navigator.mediaDevices;
    if (m == null) {
    } else {
      var _devices = await m.enumerateDevices();
      v = _devices.where((_d) => _d.kind == 'videoinput').toList();
      selectedDevice = v[0];
    }
    return Future.value(v);
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
          FutureBuilder<List<dynamic>>(
              future: getDevices(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButton<MediaDeviceInfo>(
                    value: selectedDevice,
                    items: snapshot.data!.map((val) {
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
                  );
                } else {
                  return Text("no devices");
                }
              }),
          HtmlElementView(viewType: 'videoView'),
        ],
      ),
    );
  }
}
