import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mediamapwebviewapp/screens/camera_screen.dart';
import 'package:mediamapwebviewapp/screens/google_map_screen.dart';
import 'package:mediamapwebviewapp/screens/media_screen.dart';
import 'package:mediamapwebviewapp/screens/web_view_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await availableCameras().then((value) => Navigator.push(context, 
                  MaterialPageRoute(builder: (_) => CameraScreen(cameras: value,))));
              }, 
              child: const Text('Camera Screen')
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MediaScreen()));
              }, 
              child: const Text('Media Screen')
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GoogleMapScreen()));
              }, 
              child: const Text('Google Map Screen')
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewScreen()));
              }, 
              child: const Text('WebView Screen')
            ),
          ],
        ),
      ),
    );
  }
}
