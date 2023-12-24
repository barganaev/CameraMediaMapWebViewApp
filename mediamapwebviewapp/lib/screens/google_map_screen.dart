import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double initialGoogleMapZoomLevel = 19;
const LatLng homeSweetHome = LatLng(37.42, -122.08);

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  double sliderValue = 1.0;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42, -122.08),
    zoom: 14.47
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Screen'),
      ),
      body: Stack(
        children: [

          // Google map
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
          ),

          // Zoom slider (increase / decrease)
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: GoogleMapPositionControl(
                controller: _mapController,
                initialZoomLevel: initialGoogleMapZoomLevel,
                initialPosition: homeSweetHome,
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //   },
      // ),
    );
  }
}





class GoogleMapPositionControl extends StatefulWidget {
  final Completer<GoogleMapController> controller;
  final double initialZoomLevel;
  final LatLng initialPosition;

  const GoogleMapPositionControl(
      {required this.controller,
      required this.initialZoomLevel,
      required this.initialPosition});

  @override
  State<StatefulWidget> createState() => _GoogleMapPositionControlState();
}

class _GoogleMapPositionControlState extends State<GoogleMapPositionControl> {
  late double zoomLevel;

  @override
  void initState() {
    super.initState();
    zoomLevel = widget.initialZoomLevel;
  }

  Future<void> moveCamera(
      {LatLng? position, int dx = 0, int dy = 0, double zoom = 0}) async {
    final GoogleMapController futureController = await widget.controller.future;

    double currentZoomLevel;

    if (position != null) {
      if (zoom > 0) {
        await futureController
            .moveCamera(CameraUpdate.newLatLngZoom(position, zoom));
        currentZoomLevel = await futureController.getZoomLevel();
        setState(() {
          zoomLevel = currentZoomLevel;
        });
      } else {
        futureController.moveCamera(CameraUpdate.newLatLng(position));
      }
    } else {
      if (dx != 0 || dy != 0) {
        double delta;
        currentZoomLevel = await futureController.getZoomLevel();

        if (currentZoomLevel < 10) {
          delta = 200.0;
        } else {
          delta = 150.0;
        }

        futureController
            .moveCamera(CameraUpdate.scrollBy(dx * delta, dy * delta));
      }
      if (zoom > 0) {
        await futureController.moveCamera(CameraUpdate.zoomTo(zoom));

        currentZoomLevel = await futureController.getZoomLevel();
        setState(() {
          zoomLevel = currentZoomLevel;
        });
      }
    }
  }

  void onPressedNorth() {
    moveCamera(dy: -1);
  }

  void onPressedSouth() {
    moveCamera(dy: 1);
  }

  void onPressedWest() {
    moveCamera(dx: -1);
  }

  void onPressedEast() {
    moveCamera(dx: 1);
  }

  void onPressedNorthWest() {
    moveCamera(dx: -1, dy: -1);
  }

  void onPressedNorthEast() {
    moveCamera(dx: 1, dy: -1);
  }

  void onPressedSouthWest() {
    moveCamera(dx: -1, dy: 1);
  }

  void onPressedSouthEast() {
    moveCamera(dx: 1, dy: 1);
  }

  void onChangeSlider(double sliderValue) {
    moveCamera(zoom: sliderValue);
  }

  void onPressedHome() {
    moveCamera(position: widget.initialPosition, zoom: widget.initialZoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.5),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedNorthWest,
                    icon: const Icon(Icons.north_west),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedNorth,
                    icon: const Icon(Icons.north),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedNorthEast,
                    icon: const Icon(Icons.north_east),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedWest,
                    icon: const Icon(Icons.west),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedHome,
                    icon: const Icon(Icons.home),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedEast,
                    icon: const Icon(Icons.east),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedSouthWest,
                    icon: const Icon(Icons.south_west),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedSouth,
                    icon: const Icon(Icons.south),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onPressedSouthEast,
                    icon: const Icon(Icons.south_east),
                  ),
                ],
              ),
              Slider(
                  min: 1.0,
                  max: 25.0,
                  label: zoomLevel.round().toString(),
                  //divisions: 20,
                  value: zoomLevel,
                  onChanged: (v) {
                    onChangeSlider(v);
                  })
            ],
          ),
        ),
      ),
    );
  }
}