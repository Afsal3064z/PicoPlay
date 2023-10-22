// This is the loading screen for the app
// when the app is intialised for the first time
// This loading animation is shwon when the video is fetching form the device

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

// This is the loading screen for the app
class _LoadingScreenState extends State<LoadingScreen> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("lib/assets/sqX00I3ICh.json"),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Loading",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
