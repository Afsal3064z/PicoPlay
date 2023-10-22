// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/history_database_helper.dart';
import 'package:picoplay/screens/home_screen/bottom_navigationbar.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart';

class RecentlyScreen extends StatefulWidget {
  const RecentlyScreen({Key? key}) : super(key: key);

  @override
  State<RecentlyScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<RecentlyScreen> {
  final VideoHistoryDatabaseHelper databaseHelper =
      VideoHistoryDatabaseHelper();

  bool isDeleteDialogVisible = false;
  VideoHistory? videoToDelete;
  List<VideoHistory> videos = [];
  int currentIndex = 0; // Current video index

  // Thumbnail cache
  final Map<String, Uint8List?> _thumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadVideoHistory();
  }

  // This ia the methode to load the video from the history database
  Future<void> _loadVideoHistory() async {
    final history = await databaseHelper.getVideoHistory();
    setState(() {
      videos = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavigationDemo()));
          },
          icon: const Icon(
            Icons.navigate_before,
            size: 35,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
        title: const Text("Recently Played"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: MyCustomColor.bgColor,
            stops: const [0.2, 0.8],
          ),
        ),
        child: FutureBuilder<List<VideoHistory>>(
          future: databaseHelper.getVideoHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyHistoryScreen();
            } else {
              videos = snapshot.data!;
              return _buildVideoHistoryList(videos);
            }
          },
        ),
      ),
      floatingActionButton: isDeleteDialogVisible
          ? _buildDeleteConfirmationDialog(videoToDelete!)
          : null,
    );
  }

  Widget _buildEmptyHistoryScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("lib/assets/Animation - 1696087607640.json"),
          const Text(
            "No video history available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHistoryList(List<VideoHistory> videos) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Dismissible(
          key: Key(video.videoPath),
          background: Container(
            color: Colors.deepPurple.shade600,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              isDeleteDialogVisible = true;
              videoToDelete = video;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 48, 0, 107),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: _buildVideoThumbnail(video.videoPath, video.progress),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.videoName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    video.timestamp,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isDeleteDialogVisible = true;
                    videoToDelete = video;
                  });
                },
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPaths: videos.map((video) => video.videoPath).toList(),
                    videoNames: videos.map((video) => video.videoName).toList(),
                    initialVideoIndex: index,
                    refreshCallback: () {
                      _loadVideoHistory(); // Reload the video history after returning from VideoPlayerScreen
                    },
                  ),
                ));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String videoPath, double progress) {
    if (_thumbnails.containsKey(videoPath)) {
      // Use cached thumbnail if available
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.memory(
              _thumbnails[videoPath]!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress, // Use progress directly as the value
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation(
                  Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return FutureBuilder<Uint8List?>(
        future: _generateThumbnail(videoPath),
        builder: (context, thumbnailSnapshot) {
          if (thumbnailSnapshot.connectionState == ConnectionState.waiting) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 105, 4, 219),
                highlightColor: const Color.fromARGB(197, 3, 19, 243),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.white,
                ),
              ),
            );
          } else if (thumbnailSnapshot.hasError) {
            return const Icon(
              Icons.error_outline,
              color: Colors.white,
            );
          } else if (!thumbnailSnapshot.hasData ||
              thumbnailSnapshot.data == null) {
            return const Icon(
              Icons.image,
              color: Colors.grey,
            );
          } else {
            // Cache the thumbnail
            _thumbnails[videoPath] = thumbnailSnapshot.data!;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.memory(
                    thumbnailSnapshot.data!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      value: progress, // Use progress directly as the value
                      backgroundColor: Colors.grey,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    }
  }

// The thumbnail is being generating
  Future<Uint8List?> _generateThumbnail(String videoPath) async {
    return await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 80,
      maxWidth: 60,
      maxHeight: 60,
    );
  }

  Widget _buildDeleteConfirmationDialog(VideoHistory video) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 239, 230, 255),
      title: const Text('Confirm Delete'),
      content: Text(
          'Are you sure you want to delete ${video.videoName} from history?'),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            setState(() {
              isDeleteDialogVisible = false;
              videoToDelete = null;
            });
          },
        ),
        TextButton(
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            await databaseHelper.deleteVideoHistory(video.id);

            _loadVideoHistory(); // Reload the video history after deletion

            final scaffold = ScaffoldMessenger.of(context);
            // The sanck bar when a video is deleted  from the history
            scaffold.showSnackBar(
              SnackBar(
                backgroundColor: Colors.deepPurple,
                content: Text('${video.videoName} deleted from history'),
              ),
            );

            setState(() {
              isDeleteDialogVisible = false;
              videoToDelete = null;
            });
          },
        ),
      ],
    );
  }
}
