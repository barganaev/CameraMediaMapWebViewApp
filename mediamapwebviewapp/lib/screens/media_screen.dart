import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
    );

    _videoController.addListener(() {
      if (_videoController.value.position.inSeconds != _position.inSeconds) {
        setState(() {
          _position = _videoController.value.position;
        });
      }
    });

    _videoController.setLooping(true);
    _initializeVideoPlayerFuture = _videoController.initialize().then((value) => setState(() {
      _position = _videoController.value.position;
    }));
    _videoController.play();
  }

  @override
  void dispose() {
    _videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media Screen"),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_videoController),

                  // Video scroll Slider()
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(_position.toString().split('.').first.padLeft(8, "0")),
                          Expanded(
                            child: Slider(
                              min: 0.0,
                              max: _videoController.value.duration.inSeconds
                                  .roundToDouble(),
                              value: _position.inSeconds.roundToDouble(),
                              onChanged: (double newPosition) {
                                _videoController
                                    .seekTo(Duration(seconds: newPosition.floor()));
                              },
                            ),
                          ),
                          Text(_videoController.value.duration
                              .toString()
                              .split('.')
                              .first
                              .padLeft(8, "0")),
                        ],
                      ),
                    ),
                  ),

                  // Play and Pause buttons
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      bottom: 16,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                _videoController
                                    .seekTo(_position - const Duration(seconds: 5));
                              },
                              icon: const Icon(Icons.replay_5),
                            ),
                            IconButton(
                              onPressed: () {
                                _videoController.value.isPlaying
                                    ? _videoController.pause()
                                    : _videoController.play();
                              },
                              icon: Icon(_videoController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow),
                            ),
                            IconButton(
                              onPressed: () {
                                _videoController
                                    .seekTo(_position + const Duration(seconds: 5));
                              },
                              icon: const Icon(Icons.forward_5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_videoController.value.isPlaying) {
              _videoController.pause();
            } else {
              _videoController.play();
            }
          });
        },
        child: Icon(
          _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}