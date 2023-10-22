import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart';

class AddVideosScreen extends StatefulWidget {
  final List<String> availableVideos;
  final List<String> videoNames;
  final int initialVideoIndex;

  const AddVideosScreen({
    Key? key,
    required this.availableVideos,
    required this.videoNames,
    required this.initialVideoIndex,
    required Map<String, Uint8List> videoThumbnails,
  }) : super(key: key);

  @override
  AddVideosScreenState createState() => AddVideosScreenState();
}

class AddVideosScreenState extends State<AddVideosScreen> {
  List<String> selectedVideos = [];
  List<String> filteredVideos = [];
  Map<String, Uint8List> videoThumbnails = {};

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVideos = widget.availableVideos;
    _generateVideoThumbnails();
  }

// This is the methode to filter the video
  void filterVideos(String query) {
    setState(() {
      filteredVideos = widget.availableVideos
          .where((videoPath) => widget
              .videoNames[widget.availableVideos.indexOf(videoPath)]
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

// This is the methode to generate the thumbnail of the video
  Future<void> _generateVideoThumbnails() async {
    for (final videoPath in widget.availableVideos) {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 60,
        maxWidth: 100,
        maxHeight: 100,
      );
      videoThumbnails[videoPath] = thumbnail!;
      setState(() {});
    }
  }

  String getVideoName(String videoPath) {
    final parts = videoPath.split('/');
    return parts.isNotEmpty ? parts.last : videoPath;
  }

  bool isVideoSelected(String videoPath) {
    return selectedVideos.contains(videoPath);
  }

  void toggleVideoSelection(String videoPath) {
    setState(() {
      if (isVideoSelected(videoPath)) {
        selectedVideos.remove(videoPath);
      } else {
        if (!selectedVideos.contains(videoPath)) {
          selectedVideos.add(videoPath);
        }
      }
    });
  }

  void playVideo(int index) {
    if (index >= 0 && index < filteredVideos.length) {
      final videoPath = filteredVideos[index];
      // ignore: unused_local_variable
      final videoName =
          widget.videoNames[widget.availableVideos.indexOf(videoPath)];
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPaths: widget.availableVideos,
          videoNames: widget.videoNames,
          initialVideoIndex: index,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
        title: const Text('Add Videos to Playlist'),
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
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  filterVideos(query);
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'Enter video name...',
                  hintStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  final videoPath = filteredVideos[index];
                  final videoName = getVideoName(videoPath);
                  final isSelected = isVideoSelected(videoPath);

                  return Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 48, 0, 107),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        playVideo(index);
                      },
                      title: Text(
                        videoName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      leading: videoThumbnails[videoPath] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                videoThumbnails[videoPath]!,
                                fit: BoxFit.cover,
                                width: 100,
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: const Color.fromARGB(255, 105, 4, 219),
                              highlightColor:
                                  const Color.fromARGB(197, 3, 19, 243),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      trailing: Theme(
                        data: ThemeData(
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: Checkbox(
                          shape: const CircleBorder(),
                          focusColor: Colors.white,
                          activeColor: Colors.white,
                          fillColor: MaterialStateColor.resolveWith((states) =>
                              const Color.fromARGB(255, 236, 236, 236)),
                          checkColor: Colors.deepPurple.shade900,
                          value: isSelected,
                          onChanged: (value) {
                            toggleVideoSelection(videoPath);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // This is the text button to add the selected video to the playlist
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Colors.deepPurple.shade900,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedVideos);
                },
                child: const Text(
                  'Add Selected Videos',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
