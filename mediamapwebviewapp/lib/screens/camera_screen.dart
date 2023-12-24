import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  int _selectedIndex = 0;
  XFile? _lastImage;
  final List<XFile> _lastImages = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PreviewPage(
      //       picture: picture,
      //     ),
      //   ),
      // );
      _lastImage = await _cameraController.takePicture();
      _lastImages.add(_lastImage!);
      setState(() {});
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 
        ? SafeArea(
          child: Stack(
            children: [
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator()
                    )
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                          _isRearCameraSelected
                            ? CupertinoIcons.switch_camera
                            : CupertinoIcons.switch_camera_solid,
                          color: Colors.white
                        ),
                        onPressed: () {
                          setState(() => _isRearCameraSelected = !_isRearCameraSelected);
                          initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                        },
                      )
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: takePicture,
                        iconSize: 50,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.circle, 
                          color: Colors.white
                        ),
                      ),
                    ),
                    const Spacer(),
                  ]
                ),
              ),
            ),
          ]
        ),
      ) 
      : _lastImages != null ? LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return constraints.constrainWidth() >= 600
            ? GridView.builder(
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      constraints.constrainWidth() >= 900 ? 3 : 2,
                  childAspectRatio: 2.0,
                ),
                itemCount: _lastImages.length,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(_lastImages[
                                _lastImages.length - 1 - index]
                            .path),
                        fit: BoxFit.contain,
                      ),
                    )) 
            : ListView.builder(
              itemCount: _lastImages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(_lastImages[_lastImages.length - 1 - index].path),
                  fit: BoxFit.contain,
                ),
              ),
            );
        }
      ) : const Center(
        child: Text('No images yet'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Gallery'
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// This class (screen) shows you last image (photo) and path of file
class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture.name)
        ]),
      ),
    );
  }
}