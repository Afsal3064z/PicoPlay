import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/favorite_video_database_helper.dart';
import 'package:picoplay/dataBase/play_list_database_helper.dart';
import 'package:picoplay/dataBase/video_data_base_helper.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/screens/video_fetcher_function/demo_video_fetcher_funtion.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart';

class AllVideoSection extends StatefulWidget {
  const AllVideoSection({
    Key? key,
    required List videoPaths,
  }) : super(key: key);

  @override
  State<AllVideoSection> createState() => _AllVideoSectionState();
}

class _AllVideoSectionState extends State<AllVideoSection> {
  bool _isLoading = true;
  List<String> videoPaths = [];
  Map<String, Uint8List?> thumbnails = {};
  Completer<void> thumbnailsLoadCompleter = Completer<void>();

  // Map to store favorite status of each video path
  final Map<String, bool> _isVideoFavorite = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

// This is the methode to load the video
  Future<void> _loadData() async {
    if (_isLoading && mounted) {
      final savedPaths = await VideoDatabaseHelper.instance.getVideoPaths();
      if (savedPaths.isNotEmpty) {
        final favoriteVideos =
            await FavoriteDatabaseHelper.instance.getFavorites();

        if (mounted) {
          setState(() {
            videoPaths = savedPaths;
            for (final videoPath in videoPaths) {
              final isFavorite =
                  favoriteVideos.any((video) => video.videoPath == videoPath);
              _isVideoFavorite[videoPath] = isFavorite;
            }
            _isLoading = false;
          });

          _loadThumbnails();
        }
      } else {
        await _fetchAndSaveVideoPaths();
      }
    }
  }

// This is the methode to generate the thumbnail
  Future<void> _loadThumbnails() async {
    if (videoPaths.isEmpty) {
      thumbnailsLoadCompleter.complete();
      return;
    }

    for (final videoPath in videoPaths) {
      if (!mounted) {
        return;
      }

      final thumbnail =
          thumbnails[videoPath] ?? await _getVideoThumbnail(videoPath);

      if (mounted) {
        setState(() {
          thumbnails[videoPath] = thumbnail;
        });
      }
    }

    if (mounted) {
      thumbnailsLoadCompleter.complete();
    }
  }

// This is the methode to load and save the video and it's path
  Future<void> _fetchAndSaveVideoPaths() async {
    final fetchedVideoPaths = await GetVideos.getVideos();
    await VideoDatabaseHelper.instance.insertVideoPaths(fetchedVideoPaths);

    if (mounted) {
      setState(() {
        videoPaths = fetchedVideoPaths;
        _isLoading = false;
      });
      _loadThumbnails();
    }
  }

  // methode to get the thumbnail of the video
  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 25,
      );
      return thumbnail;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.100,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade600,
            spreadRadius: 20,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.deepPurple.shade900,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        child: _buildVideoListView(),
      ),
    );
  }

// This is the methode to check weather video is favorite or note
  Future<bool> isVideoInFavorites(String videoPath) async {
    return await FavoriteDatabaseHelper.instance.isVideoInFavorites(videoPath);
  }

// This is the methode to remove the video from favorite
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

  Widget _buildVideoListView() {
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
          final videoName = videoPath.split('/').last;
          final isVideoFavorite = _isVideoFavorite[videoPath] ?? false;

          return Container(
            margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 48, 0, 107),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: thumbnails[videoPath] != null
                    ? Image.memory(
                        thumbnails[videoPath]!,
                        width: 100,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : _buildPlaceholder(),
              ),
              title: Text(
                videoName,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPaths: videoPaths,
                    videoNames: videoPaths
                        .map((videoPath) => videoPath.split('/').last)
                        .toList(),
                    initialVideoIndex: index,
                    refreshCallback: () {
                      // You can add a refresh callback here if needed
                    },
                  ),
                ));
              },
              trailing: PopupMenuButton<int>(
                color: Colors.deepPurple.shade200,
                icon: const Icon(
                  Icons.more_vert_outlined,
                  color: Colors.white,
                ),
                itemBuilder: (context) {
                  return <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: isVideoFavorite ? 1 : 0,
                      child: Text(
                        isVideoFavorite
                            ? "Remove from Favorite"
                            : "Add to Favorite",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text("Add to Playlist",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ];
                },
                onSelected: (item) async {
                  if (item == 0) {
                    final video = Video(
                      id: DateTime.now().millisecondsSinceEpoch,
                      videoPath: videoPath,
                      videoName: videoName,
                    );
                    await FavoriteDatabaseHelper.instance.insertFavorite(video);
                  } else if (item == 1) {
                    await _removeVideoFromFavorites(videoPath);
                  } else if (item == 2) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Add to Playlist"),
                          content: SingleChildScrollView(
                            child: _buildPlaylistList(videoPath),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  setState(() {});
                },
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 105, 4, 219),
      highlightColor: const Color.fromARGB(197, 3, 19, 243),
      child: Container(
        width: 100,
        height: 60,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildPlaylistList(String videoPath) {
    return FutureBuilder<List<Playlist>>(
      future: PlaylistDatabaseHelper.instance.getAllPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No playlists available.');
        } else {
          final playlists = snapshot.data;
          return Column(
            children: playlists!.map((playlist) {
              return ListTile(
                title: Text(playlist.name),
                onTap: () {
                  PlaylistDatabaseHelper.instance
                      .addVideoToPlaylist(playlist.name, videoPath);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}
