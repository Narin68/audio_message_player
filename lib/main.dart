import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:record/record.dart';
import 'package:remixicon/remixicon.dart';
import 'package:voice_message_package/voice_message/src/voice_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _isRecording = false;

  AnimationController? _controller;
  ThemeData? theme;

  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  double value = 0;
  String path = '';
  Uint8List? bytes;
  File? file;
  Color caughtColor = Colors.red;
  String url =
      'https://firebasestorage.googleapis.com/v0/b/wefix4utoday.appspot.com/o/message%2Faudio%2FMA06072023903.m4a?alt=media&token=8a8badc5-897e-4be8-9d8e-0a4743df4dcb';
  List<String> paths = [];
  int _getCount = 0;
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future _init() async {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    _controller?.addListener(() {
      // print("======> ${_controller?.value}");
      if (_controller?.isCompleted ?? false) {
        _controller?.reset();
        _isRecording = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        if (_isRecording) {
          _isRecording = false;
          _controller?.stop();
        } else {
          _isRecording = true;
          _controller?.forward();
        }
        setState(() {});
      }),
      body: Parent(
        style: ParentStyle(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_controller != null && _isRecording)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Parent(
                    style: ParentStyle(),
                    gesture: Gestures()
                      ..onTap(() async {
                        _isRecording = false;
                        _timer?.cancel();
                        _ampTimer?.cancel();
                        _controller?.reset();
                        await _audioRecorder.stop();
                        setState(() {});
                      }),
                    child: const Icon(
                      Remix.close_circle_fill,
                      color: Color(0xffC22F27),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Parent(
                    style: ParentStyle()
                      ..height(30)
                      ..width(200)
                      ..overflow.hidden()
                      ..borderRadius(all: 15),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        if (_controller != null)
                          AnimatedBuilder(
                            animation: CurvedAnimation(
                                parent: _controller!, curve: Curves.ease),
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                minHeight: 30,
                                backgroundColor:
                                    const Color.fromARGB(255, 207, 53, 45),
                                value: _controller?.value ?? 0,
                                color: const Color(0xffC22F27),
                              );
                            },
                          ),
                        Positioned(
                          top: 4.5,
                          left: 5,
                          child: Parent(
                            style: ParentStyle()
                              ..borderRadius(all: 50)
                              ..width(20)
                              ..height(20)
                              ..background.color(Colors.white),
                            child: const Icon(
                              Icons.rectangle_rounded,
                              size: 12,
                              color: Color(0xffC22F27),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 7,
                          child: Text(
                            _recordDuration >= 60
                                ? "1 : 00"
                                : "0 : ${_recordDuration < 10 ? "0$_recordDuration" : _recordDuration}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Parent(
                    style: ParentStyle(),
                    gesture: Gestures()
                      ..onTap(() async {
                        _stop();
                      }),
                    child: const Icon(
                      Remix.send_plane_2_fill,
                      size: 20,
                      color: Color(0xffC22F27),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            VoiceMessage(
              audioSrc: url,
              played: false, // To show played badge or not.
              me: true, // Set message side.
              onPlay: () {},
              meBgColor: const Color(0xffC22F27),
              // Do something when voice played.
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _start();
              },
              child: const Text("Start Recording"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller?.reset();
                _stop();
              },
              child: const Text("Stop Recording"),
            ),
            const SizedBox(height: 20),
            Draggable(
              data: Colors.orangeAccent,
              // calling onDraggableCanceled property

              onDraggableCanceled: (velocity, offset) {
                print("Hello");
              },
              feedback: SpinKitPulse(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? const Color(0xffC22F27)
                          : const Color.fromRGBO(209, 87, 87, 1),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  );
                },
              ),
              child: const Icon(Icons.mic),
            ),
            // const SizedBox(height: 25),
            // // building Drag Target Widget
            // DragTarget(onAccept: (Color color) {
            //   caughtColor = color;
            // }, builder: (
            //   BuildContext context,
            //   List<dynamic> accepted,
            //   List<dynamic> rejected,
            // ) {
            //   return Container(
            //     width: 200,
            //     height: 200,
            //     color: accepted.isEmpty ? caughtColor : Colors.grey.shade200,
            //     child: const Center(
            //       child: Text('Drag here'),
            //     ),
            //   );
            // }),
            const SizedBox(height: 25),

            const SizedBox(height: 25),
            Expanded(
              child: ListView.builder(
                itemCount: paths.length,
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Parent(
                        style: ParentStyle()..margin(bottom: 10),
                        child: VoiceMessage(
                          audioSrc: paths[i],
                          played: false, // To show played badge or not.
                          me: true, // Set message side.
                          onPlay: () {},
                          meBgColor: Color(0xffC22F27),
                          // Do something when voice played.
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    _isRecording = true;
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
          value = 0;
        });
        _controller?.forward();
        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();
    file = null;
    bytes = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      value = _recordDuration / 60;
      setState(() {});
      if (_recordDuration > 59) {
        _stop();
        _controller?.reset();
      }
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      setState(() {});
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    _controller?.reset();
    file = null;
    bytes = null;
    setState(() {});

    final audioPath = await _audioRecorder.stop();

    if (audioPath != null) {
      path = audioPath.replaceAll('file://', '');
      paths.add(path);
      file = await _localFile(audioPath);
      bytes = await file?.readAsBytes();
      _recordDuration = 0;
      setState(() => _isRecording = false);
    }
  }

  Future<File> _localFile(String path) async {
    return File(path.replaceAll('file://', '')).create();
  }
}
