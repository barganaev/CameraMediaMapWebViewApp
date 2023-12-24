import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mediamapwebviewapp/screens/main_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MyApp(/*camers: cameras,*/));
}

class MyApp extends StatefulWidget {
  MyApp({
    super.key,
/*    required this.camers*/
  });
  
/*  List<CameraDescription> camers;*/

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MainScreen()
    );
  }
}
