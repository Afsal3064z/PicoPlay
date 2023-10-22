import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picoplay/dataBase/history_database_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> videoPaths; // List of video paths
  final List<String> videoNames; // List of video names
  final int initialVideoIndex; // Index of the initial video to play
  final double? initialSeek;
  final VoidCallback? refreshCallback;
  final Uint8List? thumbnail;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPaths,
    required this.videoNames,
    required this.initialVideoIndex,
    this.refreshCallback,
    this.initialSeek,
    this.thumbnail,
  }) : super(key: key);

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _volume = 1.0;
  // ignore: unused_field
  String _volumePercentage = '';
  double _currentSliderValue = 0.0;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _showAppBar = true;
  bool isSeeking = false;
  int currentVideoIndex = 0;
  final VideoHistoryDatabaseHelper databaseHelper =
      VideoHistoryDatabaseHelper();
  late double _savedProgress;

  @override
  void initState() {
    super.initState();
    _savedProgress = 0.0;

    _loadSavedProgress();

    currentVideoIndex = widget.initialVideoIndex;
    _controller =
        VideoPlayerController.file(File(widget.videoPaths[currentVideoIndex]))
          ..initialize().then((_) {
            setState(() {});
            _controller.seekTo(Duration(seconds: _savedProgress.toInt()));
            _controller.play();
          });

    _controller.addListener(() {
      if (mounted && !isSeeking) {
        setState(() {
          _currentSliderValue = _controller.value.position.inSeconds.toDouble();
        });
      }
    });

    getExistingVideoHistory();
  }

  Future<void> _loadSavedProgress() async {
    final progress = await databaseHelper
        .getVideoProgressByPath(widget.videoPaths[currentVideoIndex]);
    setState(() {
      _savedProgress = progress;
    });
  }

  void _saveProgress(double progress) {
    databaseHelper.updateVideoProgress(
        widget.videoPaths[currentVideoIndex], progress);
  }

  void getExistingVideoHistory() async {
    final existingVideo = await databaseHelper
        .getVideoHistoryByPath(widget.videoPaths[currentVideoIndex]);

    if (existingVideo != null) {
      showResumeAlert(existingVideo);
    } else {
      saveVideoHistory();
    }
  }

  void updateVideoHistory(VideoHistory existingVideo) async {
    final now = DateTime.now();
    final timestamp = now.toLocal().toString();

    final updatedVideoHistory = VideoHistory(
      id: existingVideo.id,
      videoPath: widget.videoPaths[currentVideoIndex],
      videoName: widget.videoNames[currentVideoIndex],
      timestamp: timestamp,
      progress: _currentSliderValue,
    );

    await databaseHelper.updateVideoHistory(updatedVideoHistory);
  }

  void saveVideoHistory() async {
    final now = DateTime.now();
    final timestamp = now.toLocal().toString();
    final videoHistory = VideoHistory(
      videoPath: widget.videoPaths[currentVideoIndex],
      videoName: widget.videoNames[currentVideoIndex],
      timestamp: timestamp,
      progress: _currentSliderValue,
    );

    await databaseHelper.insertVideoHistory(videoHistory);
  }

  void playNextVideo() {
    final int nextVideoIndex = currentVideoIndex + 1;
    if (nextVideoIndex < widget.videoPaths.length) {
      playVideoAtIndex(nextVideoIndex);
    } else {
      // Show a snackbar if there are no more videos to play
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more videos to play.')),
      );
    }
  }

  void playPreviousVideo() {
    final int previousVideoIndex = currentVideoIndex - 1;
    if (previousVideoIndex >= 0) {
      playVideoAtIndex(previousVideoIndex);
    } else {
      // Show a snackbar if you're at the beginning of the video list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are at the beginning of the list.')),
      );
    }
  }

  void playVideoAtIndex(int index) {
    if (index >= 0 && index < widget.videoPaths.length) {
      currentVideoIndex = index;
      // ignore: unused_local_variable
      final nextVideoPath = widget.videoPaths[currentVideoIndex];
      // ignore: unused_local_variable
      final nextVideoName = widget.videoNames[currentVideoIndex];

      databaseHelper.updateVideoProgress(
          widget.videoPaths[currentVideoIndex], _currentSliderValue);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPaths: widget.videoPaths,
          videoNames: widget.videoNames,
          initialVideoIndex: currentVideoIndex,
        ),
      ));
    } else {
      // Show a snackbar if there are no more videos to play
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more videos to play.')),
      );
    }
  }

  void seekToPosition(double value) {
    final Duration newPosition = Duration(seconds: value.toInt());
    _controller.seekTo(newPosition);
  }

  void toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;

      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  void toggleAppBarVisibility() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  void toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void toggleMute() {
    setState(() {
      if (_volume == 0.0) {
        _volume = 1.0;
      } else {
        _volume = 0.0;
      }
      _controller.setVolume(_volume);
      _updateVolumePercentage();
    });
  }

  void _updateVolumePercentage() {
    final int percentage = (_volume * 100).toInt();
    _volumePercentage = '$percentage%';

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _volumePercentage = '';
      });
    });
  }

  @override
  void dispose() {
    databaseHelper.updateVideoProgress(
        widget.videoPaths[currentVideoIndex], _currentSliderValue);

    super.dispose();
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void showResumeAlert(VideoHistory existingVideo) {
    _controller.pause(); // Pause the video

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Resume Video"),
          content: const Text(
              "Do you want to resume from where you left off or start over?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Start Over"),
              onPressed: () {
                Navigator.of(context).pop();
                _currentSliderValue = 0.0;
                _controller.seekTo(const Duration(seconds: 0));
                _controller.play(); // Start over by playing the video
              },
            ),
            TextButton(
              child: const Text("Resume"),
              onPressed: () {
                Navigator.of(context).pop();
                final Duration position =
                    Duration(seconds: _savedProgress.toInt());
                _controller.seekTo(position);
                _controller.play(); // Resume playing the video
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? PreferredSize(
              preferredSize:
                  _showAppBar ? const Size.fromHeight(80) : Size.zero,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: const Offset(0, 0),
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF3E008C),
                            Color.fromARGB(0, 72, 0, 166)
                          ],
                          stops: [0.5, 20],
                        ),
                      ),
                      child: AppBar(
                        leading: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.navigate_before),
                        ),
                        backgroundColor: Colors.transparent,
                        title: Text(widget.videoNames[currentVideoIndex]),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
      body: GestureDetector(
        onTap: () {
          toggleAppBarVisibility();
          toggleControlsVisibility();
        },
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final aspectRatio = isLandscape
                ? screenWidth / screenHeight
                : _controller.value.aspectRatio;

            final videoPlayer = AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(children: [
                VideoPlayer(_controller),
                if (!_controller.value.isInitialized || isSeeking)
                  const Center(child: CircularProgressIndicator()),
              ]),
            );

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  videoPlayer,
                  Visibility(
                    visible: _showControls,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xFF3E008C),
                                Color.fromARGB(0, 72, 0, 166)
                              ],
                              stops: [0.0, 0.7],
                            ),
                          ),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6.0),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 10.0),
                                    trackHeight: 2.0,
                                    activeTrackColor:
                                        Colors.deepPurple.shade700,
                                    thumbColor: Colors.deepPurple.shade700),
                                child: Slider(
                                  value: _currentSliderValue,
                                  min: 0.0,
                                  max: _controller.value.duration.inSeconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _saveProgress(value);
                                    seekToPosition(value);
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      _volume == 0.0
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: toggleMute,
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius: 6.0),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                  overlayRadius: 10.0),
                                          trackHeight: 2.0,
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.grey,
                                          thumbColor: Colors.white),
                                      child: Slider(
                                        value: _volume,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: (value) {
                                          setState(() {
                                            _volume = value;
                                            _controller.setVolume(_volume);
                                            _updateVolumePercentage();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_previous,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: playPreviousVideo,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_controller.value.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: playNextVideo,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.rotate_90_degrees_ccw,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: toggleFullScreen,
                                  ),
                                  if (isSeeking)
                                    const CircularProgressIndicator()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
