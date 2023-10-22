import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/favorite_video_database_helper.dart';
import 'package:picoplay/dataBase/video_data_base_helper.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/screens/video_fetcher_function/demo_video_fetcher_funtion.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  bool _isLoading = false;
  List<String> videoPaths = [];
  List<String> videoNames = [];
  int initialVideoIndex = 0; // Set the initial index here
  Map<String, Uint8List?> thumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      final savedPaths = await VideoDatabaseHelper.instance.getVideoPaths();
      if (savedPaths.isNotEmpty) {
        setState(() {
          videoPaths = savedPaths;
          videoNames = savedPaths.map((path) => path.split('/').last).toList();
          _isLoading = false;
        });
      } else {
        await _fetchAndSaveVideoPaths();
      }
    }
  }

  Future<void> _fetchAndSaveVideoPaths() async {
    final fetchedVideoPaths = await GetVideos.getVideos();
    final first10Paths = fetchedVideoPaths.take(10).toList();

    await VideoDatabaseHelper.instance.insertVideoPaths(first10Paths);

    setState(() {
      videoPaths = first10Paths;
      videoNames = first10Paths.map((path) => path.split('/').last).toList();
      _isLoading = false;
    });

    for (final path in fetchedVideoPaths.skip(10)) {
      await VideoDatabaseHelper.instance.insertVideoPaths(path as List<String>);
    }
  }

  Future<bool> isVideoInFavorites(String videoPath) async {
    final favorites = await FavoriteDatabaseHelper.instance.getFavorites();
    return favorites.any((video) => video.videoPath == videoPath);
  }

  Future<void> _removeVideoFromFavorites(String videoPath) async {
    final favorites = await FavoriteDatabaseHelper.instance.getFavorites();
    final video = favorites.firstWhere(
      (video) => video.videoPath == videoPath,
      orElse: () => Video(id: -1, videoPath: "", videoName: ""),
    );

    if (video.id != -1) {
      await FavoriteDatabaseHelper.instance.removeFavorite(video.id);
    }
  }

  Future<void> toggleFavoriteStatus(String videoPath, String videoName) async {
    final isFavorite = await isVideoInFavorites(videoPath);

    if (isFavorite) {
      await _removeVideoFromFavorites(videoPath);
    } else {
      final video = Video(
        id: DateTime.now().millisecondsSinceEpoch,
        videoPath: videoPath,
        videoName: videoName,
      );
      await FavoriteDatabaseHelper.instance.insertFavorite(video);
    }
    setState(() {});
  }

  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      maxWidth: 120,
      quality: 25,
    );
    return thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
        title: const Text('All Videos'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: MyCustomColor.bgColor,
                stops: const [0.2, 0.8],
              ),
            ),
            child: _buildVideoListView(context),
          );
        },
      ),
    );
  }

  Widget _buildVideoListView(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (videoPaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("lib/assets/Animation - 1696088228659.json"),
            const Text(
              'No videos found Oops.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          final videoPath = videoPaths[index];
          final videoName = videoNames[index];

          return Container(
            margin: const EdgeInsets.only(top: 15, left: 12, right: 12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 48, 0, 107),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ListTile(
              title: Text(
                'Video $index',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                videoName,
                style: const TextStyle(color: Colors.white),
              ),
              leading: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: FutureBuilder<Uint8List?>(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data != null
                          ? Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: 100,
                            )
                          : _buildPlaceholder();
                    } else {
                      return _buildPlaceholder();
                    }
                  },
                  future: _getVideoThumbnail(videoPath),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    refreshCallback: () {},
                    videoPaths: videoPaths, // Pass videoPaths
                    videoNames: videoNames, // Pass videoNames
                    initialVideoIndex: index, // Pass initialVideoIndex
                  ),
                ));
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      // Use Shimmer for the placeholder
      baseColor: const Color.fromARGB(255, 105, 4, 219),
      highlightColor: const Color.fromARGB(197, 3, 19, 243),
      child: Container(
        width: 100,
        height: 60,
        color: Colors.grey[400],
      ),
    );
  }
}
