// ignore_for_file: must_be_immutable
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:picoplay/dataBase/play_list_database_helper.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PlayListViewScreen extends StatefulWidget {
  String playlistName;
  final Function() refreshPlaylists;

  PlayListViewScreen({
    Key? key,
    required this.playlistName,
    required this.refreshPlaylists,
  }) : super(key: key);

  @override
  PlayListViewScreenState createState() => PlayListViewScreenState();
}

class PlayListViewScreenState extends State<PlayListViewScreen> {
  String playlistDescription = '';
  List<String> playlistVideos = [];
  final Map<String, Uint8List?> videoThumbnails = {};
  TextEditingController playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPlaylistDetails();
  }

  @override
  void dispose() {
    super.dispose();
    playlistNameController.dispose();
  }

  Future<void> loadPlaylistDetails() async {
    final playlist = await PlaylistDatabaseHelper.instance
        .fetchPlaylistByName(widget.playlistName);

    if (playlist != null) {
      setState(() {
        playlistDescription = playlist.description;
        playlistVideos = playlist.videos;
      });
    }

    await generateThumbnails();
  }

  Future<void> generateThumbnails() async {
    for (final videoPath in playlistVideos) {
      final thumbnail = await getVideoThumbnail(videoPath);
      if (mounted) {
        setState(() {
          videoThumbnails[videoPath] = thumbnail;
        });
      }
    }
  }

  Future<Uint8List?> getVideoThumbnail(String videoPath) async {
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

  void deleteVideoFromPlaylist(int index) async {
    final videoPath = playlistVideos[index];
    final videoName = getVideoName(videoPath);

    setState(() {
      playlistVideos.removeAt(index);
      videoThumbnails.remove(videoPath);
    });

    await PlaylistDatabaseHelper.instance.updatePlaylistVideos(
      widget.playlistName,
      playlistVideos,
    );

    // ignore: use_build_context_synchronously
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepPurple,
        content: Text('$videoName deleted from the playlist'),
      ),
    );
  }

  String getVideoName(String videoPath) {
    final parts = videoPath.split('/');
    return parts.isNotEmpty ? parts.last : videoPath;
  }

  void editPlaylistName() {
    playlistNameController.text = widget.playlistName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Playlist Name'),
          content: TextField(
            controller: playlistNameController,
            decoration: const InputDecoration(
              hintText: 'Enter new playlist name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newPlaylistName = playlistNameController.text;
                if (newPlaylistName.isNotEmpty) {
                  await PlaylistDatabaseHelper.instance.editPlaylistName(
                    widget.playlistName,
                    newPlaylistName,
                  );

                  widget.refreshPlaylists();
                  setState(() {
                    widget.playlistName = newPlaylistName;
                  });

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              editPlaylistName();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 48, 0, 107), Colors.deepPurple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (playlistVideos.isEmpty)
              const Center(
                child: Text(
                  'Add videos to the playlist.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: playlistVideos.length,
                  itemBuilder: (context, index) {
                    final videoPath = playlistVideos[index];
                    final videoName = getVideoName(videoPath);
                    return Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 48, 0, 107),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(
                          videoName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoPaths: playlistVideos,
                              videoNames:
                                  playlistVideos.map(getVideoName).toList(),
                              initialVideoIndex: index,
                              refreshCallback: () {},
                              thumbnail: videoThumbnails[videoPath],
                            ),
                          ));
                        },
                        leading: ShimmerThumbnail(
                          thumbnailFuture: getVideoThumbnail(videoPath),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            deleteVideoFromPlaylist(index);
                          },
                        ),
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
}

class ShimmerThumbnail extends StatelessWidget {
  final Future<Uint8List?> thumbnailFuture;

  const ShimmerThumbnail({Key? key, required this.thumbnailFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      builder: (context, thumbnailSnapshot) {
        if (thumbnailSnapshot.connectionState == ConnectionState.waiting ||
            thumbnailSnapshot.connectionState == ConnectionState.none ||
            thumbnailSnapshot.data == null ||
            thumbnailSnapshot.data!.isEmpty) {
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 105, 4, 219),
            highlightColor: const Color.fromARGB(197, 3, 19, 243),
            child: SizedBox(
              width: 100,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (thumbnailSnapshot.hasError) {
          return const SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
        } else {
          return SizedBox(
            width: 100,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                thumbnailSnapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
      future: thumbnailFuture,
    );
  }
}
