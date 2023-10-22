import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:picoplay/dataBase/favorite_video_database_helper.dart';
import 'package:picoplay/dataBase/play_list_database_helper.dart';
import 'package:picoplay/screens/home_screen/bottom_navigationbar.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:picoplay/dataBase/video_data_base_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SearchListView extends StatefulWidget {
  const SearchListView({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchListView> createState() => _SearchListViewState();
}

class _SearchListViewState extends State<SearchListView> {
  TextEditingController searchController = TextEditingController();
  List<String> allVideoPaths = [];
  List<String> filteredVideoPaths = [];
  Map<String, Uint8List> thumbnailCache = {};
  bool isLoading = true;
  late Completer<void> _thumbnailsCompleter;

  @override
  void initState() {
    super.initState();
    _thumbnailsCompleter = Completer<void>();
    loadVideoPathsFromDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: unnecessary_null_comparison
    if (_thumbnailsCompleter != null && !_thumbnailsCompleter.isCompleted) {
      _thumbnailsCompleter.complete();
    }
  }

  void loadVideoPathsFromDatabase() async {
    final paths = await VideoDatabaseHelper.instance.getVideoPaths();
    allVideoPaths = paths;
    filteredVideoPaths = paths;
    // Thumbnails are initially empty, will be loaded on-demand
    // thumbnails = List.generate(paths.length, (_) => null);

    setState(() {
      isLoading = false;
    });
  }

  Future<Uint8List?> loadThumbnails(String videoPath) async {
    if (thumbnailCache.containsKey(videoPath)) {
      // Use cached thumbnail if available
      return thumbnailCache[videoPath];
    }

    final Uint8List? thumbnail = await _getVideoThumbnail(videoPath);
    thumbnailCache[videoPath] = thumbnail!;
    return thumbnail;
  }

  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 25,
    );
    return thumbnail;
  }

  void filterVideoPaths(String query) {
    setState(() {
      filteredVideoPaths = allVideoPaths.where((path) {
        final videoName = path.split('/').last.toLowerCase();
        return videoName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavigationDemo()));
          },
          child: const Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 36,
          ),
        ),
        title: const Text(
          "Search Videos",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                onChanged: filterVideoPaths,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  hintText: 'Enter Video Name',
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      searchController.clear();
                      loadVideoPathsFromDatabase();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredVideoPaths.isEmpty
                      ? const Center(
                          child: Text(
                            'No videos found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredVideoPaths.length,
                          itemBuilder: (context, index) {
                            final videoPath = filteredVideoPaths[index];
                            final videoName = videoPath.split('/').last;

                            return Container(
                              margin: const EdgeInsets.only(
                                  top: 15, left: 12, right: 12),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 48, 0, 107),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text(
                                  videoName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                leading: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: FutureBuilder<Uint8List?>(
                                    future: loadThumbnails(videoPath),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return snapshot.data != null
                                            ? Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                              )
                                            : _buildPlaceholder();
                                      } else {
                                        return SizedBox(
                                          width: 100,
                                          height: 60,
                                          child: Shimmer.fromColors(
                                            baseColor: const Color.fromARGB(
                                                255, 105, 4, 219),
                                            highlightColor:
                                                const Color.fromARGB(
                                                    197, 3, 19, 243),
                                            child: Container(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'addToPlaylist') {
                                      _showAddToPlaylistDialog(videoPath);
                                    } else if (value == 'addToFavorites') {
                                      addToFavorites(videoPath);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'addToPlaylist',
                                        child: Text('Add to Playlist'),
                                      ),
                                    ];
                                  },
                                ),
                                onTap: () {
                                  final videoPath = filteredVideoPaths[index];
                                  // ignore: unused_local_variable
                                  final videoName = videoPath.split('/').last;
                                  const initialSeek =
                                      0.0; // You can set the initial seek position here

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        videoPaths:
                                            allVideoPaths, // Pass the list of all video paths
                                        videoNames: allVideoPaths
                                            .map((path) => path.split('/').last)
                                            .toList(), // Pass the list of all video names
                                        initialVideoIndex:
                                            index, // Pass the initial index
                                        initialSeek: initialSeek,
                                        refreshCallback:
                                            loadVideoPathsFromDatabase,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(String videoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: SizedBox(
            height: 200, // Set the desired height here
            child: _buildPlaylistList(videoPath),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addToFavorites(String videoPath) async {
    final isFav =
        await FavoriteDatabaseHelper.instance.isVideoInFavorites(videoPath);

    if (!isFav) {
      final videoName = videoPath.split('/').last;
      final video = Video(id: 0, videoPath: videoPath, videoName: videoName);
      await FavoriteDatabaseHelper.instance.insertFavorite(video);
    } else {
      await FavoriteDatabaseHelper.instance.removeFavorite(videoPath as int);
    }

    loadVideoPathsFromDatabase();
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 105, 4, 219),
      highlightColor: const Color.fromARGB(197, 3, 19, 243),
      child: Container(
        width: 100,
        height: 60,
        color: Colors.white,
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
                      .updatePlaylistVideos(playlist.name, [videoPath]);
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
