import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/dataBase/history_database_helper.dart';
import 'package:picoplay/screens/home_screen/custom_widegets_home.dart';
import 'package:picoplay/screens/home_screen/second_half_home_page.dart';
import 'package:picoplay/screens/player/player_screen.dart';
import 'package:picoplay/screens/recentlyPlayed_screen/recently_played_screen.dart';
import 'package:picoplay/screens/search_screen/search_listview.dart';
import 'package:picoplay/screens/video_fetcher_function/all_video_list.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VideoHistoryDatabaseHelper databaseHelper =
      VideoHistoryDatabaseHelper();
  List<VideoHistory> historyVideos = [];
  bool shouldShowCarousel = false;
  bool isFetchingVideos = true;

  @override
  void initState() {
    super.initState();
    databaseHelper.open();
    fetchHistoryVideos();
  }

// This is the methode to fetch the video from the history
  Future<void> fetchHistoryVideos() async {
    final history = await databaseHelper.getVideoHistory();
    if (mounted) {
      setState(() {
        historyVideos = history;
        shouldShowCarousel = historyVideos.length >= 4;
        isFetchingVideos = false;
      });
    }
  }

  void refreshCarousel() {
    setState(() {
      // Refresh the CarouselSlider
    });
  }

// This is the methode to refresh the screen
  Future<void> refreshHistoryVideos() async {
    setState(() {
      isFetchingVideos = true;
    });
    final history = await databaseHelper.getVideoHistory();
    if (mounted) {
      setState(() {
        historyVideos = history;
        shouldShowCarousel = historyVideos.length >= 4;
        isFetchingVideos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: MyCustomColor.bgColor,
              stops: const [0.2, 0.8],
            ),
          ),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return false;
            },
            child: ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 10,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchListView(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        color: Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                //This is the  where the corosal of the recently played is displayed
                const CustomHeaderForHomePage(
                  title: 'Recently Played',
                  seeAllScreen: RecentlyScreen(),
                ),
                if (isFetchingVideos)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!isFetchingVideos && historyVideos.isNotEmpty)
                  CarouselSlider(
                    items: historyVideos.take(10).map((video) {
                      int index = historyVideos.indexOf(video);
                      return GestureDetector(
                        onTap: () async {
                          final updatedVideo = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoPaths: historyVideos
                                    .map((v) => v.videoPath)
                                    .toList(),
                                videoNames: historyVideos
                                    .map((v) => v.videoName)
                                    .toList(),
                                initialVideoIndex: index,
                                initialSeek: video.progress,
                              ),
                            ),
                          );
                          if (updatedVideo != null) {
                            refreshHistoryVideos();
                          }
                        },
                        child: CustomCorosel(
                          movie: video.videoName,
                          videoPath: video.videoPath,
                          progress: video.progress,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.30,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                    ),
                  ),
                if (!isFetchingVideos && !shouldShowCarousel)
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Lottie.asset(
                              "lib/assets/animation_lnbg4abg.json"),
                        ),
                        const Text(
                          "Not enough videos in history to show CarouselSlider.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const CustomHeaderForHomePage(
                  title: 'All Video',
                  //This is will navigate to the all the video in the device
                  seeAllScreen: VideoListScreen(),
                ),
                const SizedBox(
                  height: 600,
                  //This is the all video section in the second half of the video player
                  child: AllVideoSection(
                    videoPaths: [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
