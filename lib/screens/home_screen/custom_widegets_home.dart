import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/////////////////////////////////////////////////////////////////////
///This is the custom widgets for the app///
/////////////////////////////////////////////////////////////////////
///This is the custom corosel for the home page app///
import 'package:video_thumbnail/video_thumbnail.dart';

class CustomCorosel extends StatelessWidget {
  final String movie;
  final String videoPath;
  final double progress;

  const CustomCorosel({
    required this.movie,
    required this.videoPath,
    required this.progress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _generateVideoThumbnail(),
      builder: (context, thumbnailSnapshot) {
        if (thumbnailSnapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 105, 4, 219),
            highlightColor: const Color.fromARGB(197, 3, 19, 243),
            child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white, // Shimmer effect color
              ),
            ),
          );
        } else if (thumbnailSnapshot.hasError ||
            thumbnailSnapshot.data == null) {
          return const Icon(Icons.error);
        } else {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(thumbnailSnapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 38, 2, 82),
                      Color.fromARGB(0, 72, 0, 166),
                    ],
                    stops: [0.0, 0.7],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width * 0.95,
                height: 250,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  movie,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

//This is the methode to generate the thumbnail
  Future<Uint8List?> _generateVideoThumbnail() async {
    try {
      // Verify that the video file exists
      final videoFile = File(videoPath);
      if (!videoFile.existsSync()) {
        return null; // Video file does not exist
      }

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 100,
        maxWidth: 150,
        maxHeight: 150,
      );
      return thumbnail;
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Error generating thumbnail: $e');
      // ignore: avoid_print
      print(stackTrace);
      return null;
    }
  }
}

///////////////////////////////////////////////////////////////////
///This is the custom Header for the Home page///
class CustomHeaderForHomePage extends StatefulWidget {
  const CustomHeaderForHomePage({
    Key? key,
    required this.title,
    required this.seeAllScreen, // Accept a screen for navigation
  }) : super(key: key);

  final String title;
  final Widget seeAllScreen; // Screen to navigate to

  @override
  State<CustomHeaderForHomePage> createState() =>
      CustomHeaderForHomePageState();
}

class CustomHeaderForHomePageState extends State<CustomHeaderForHomePage> {
  bool isLoading = true; // Flag to track loading

  @override
  void initState() {
    super.initState();

    // Simulate loading data with a delay (you should replace this with your actual data loading)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false; // Set loading to false when data is loaded
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              // Navigate to the specified screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return widget.seeAllScreen;
              }));
            },
            child: const Text(
              "see all",
              style: TextStyle(
                color: Color.fromARGB(255, 48, 243, 55),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
///This is the custome Route animation for the app///
class CustomPageRoute extends PageRouteBuilder {
  CustomPageRoute(Widget page)
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start off-screen
            const end = Offset.zero;
            const curve = Curves.easeInOut; // Use ease-in-out curve

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
