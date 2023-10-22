// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/favorite_video_database_helper.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Video> favoriteVideos = [];
  bool _isDisposed = false;
  Map<int, Uint8List?> thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteVideos();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Method to load favorite videos from the favorite database
  Future<void> _loadFavoriteVideos() async {
    if (_isDisposed) {
      return;
    }
    final favorites = await FavoriteDatabaseHelper.instance.getFavorites();
    if (!_isDisposed) {
      setState(() {
        favoriteVideos = favorites;
      });
    }
  }

  // Method to remove a video from the database (favorite database)
  Future<void> _removeFavorite(Video video) async {
    if (_isDisposed) {
      return;
    }
    await FavoriteDatabaseHelper.instance.removeFavorite(video.id);
    if (!_isDisposed) {
      setState(() {
        favoriteVideos.remove(video);
      });
      // Show a snackbar when the video is removed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepPurple.shade500,
          content: Text('${video.videoName} removed from favorites'),
        ),
      );
    }
  }

  // Generate or retrieve a thumbnail from the cache
  Future<Uint8List?> _getOrGenerateThumbnail(
      int videoId, String videoPath) async {
    if (thumbnailCache.containsKey(videoId)) {
      return thumbnailCache[videoId];
    } else {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 80,
        maxWidth: 60,
        maxHeight: 60,
      );
      thumbnailCache[videoId] = thumbnail;
      return thumbnail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: MyCustomColor.bgColor,
            stops: const [0.2, 0.8],
          ),
        ),
        child: favoriteVideos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("lib/assets/Animation - 1696089090324.json"),
                    const Text(
                      'No favorite videos found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: favoriteVideos.length,
                itemBuilder: (context, index) {
                  final video = favoriteVideos[index];
                  return Dismissible(
                    key: Key(video.id.toString()),
                    background: Container(
                      color: Colors.deepPurple.shade600,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      _removeFavorite(video);
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
                        leading: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: SizedBox(
                            width: 100,
                            height: 60,
                            child: FutureBuilder<Uint8List?>(
                              future: _getOrGenerateThumbnail(
                                  video.id, video.videoPath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor:
                                        const Color.fromARGB(255, 105, 4, 219),
                                    highlightColor:
                                        const Color.fromARGB(197, 3, 19, 243),
                                    child: Container(
                                      width: 100,
                                      height: 60,
                                      color: Colors
                                          .grey, // Use a background color for shimmer effect
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return const SizedBox(
                                    width: 100,
                                    height: 60,
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const SizedBox(
                                    width: 100,
                                    height: 60,
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  );
                                } else {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        title: Text(
                          video.videoName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoPaths: favoriteVideos
                                  .map((video) => video.videoPath)
                                  .toList(),
                              videoNames: favoriteVideos
                                  .map((video) => video.videoName)
                                  .toList(),
                              initialVideoIndex: index,
                              refreshCallback: () {
                                _loadFavoriteVideos(); // Refresh favorite videos after returning from VideoPlayerScreen
                              },
                            ),
                          ));
                        },
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _removeFavorite(video);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
