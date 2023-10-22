// This is the landing page  of the app and 
// in this screen the permission is handled for 
// for different version of the android os by the device info 
 

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picoplay/screens/home_screen/bottom_navigationbar.dart';
import 'package:picoplay/theme_data/theme_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _HomePageState();
}

class _HomePageState extends State<LandingPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Perform any asynchronous initialization here if needed.
    // For example, you can start loading assets.
  }
 // Methode to get the permission to the media of the device 
  Future<void> requestPermissionForStorage(BuildContext context) async {
    final AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    PermissionStatus permissionStatus;

    if (build.version.sdkInt >= 33) {
      permissionStatus = await Permission.videos.request();
    } else {
      permissionStatus = await Permission.storage.request();
    }

    if (permissionStatus.isGranted) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isIntroductionShown', true);

      // Start loading assets or data asynchronously
      setState(() {
        isLoading = true;
      });

      // Simulate a delay for loading (replace with actual loading logic)
      await Future.delayed(const Duration(seconds: 10));

      // Navigate to the next screen after assets are loaded
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const BottomNavigationDemo(),
      ));
    } else {
      // Permission denied, show an alert dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
                "This app requires storage permission to function properly"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("lib/assets/sqX00I3ICh.json"),
                    const Text(
                      "Loading",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ), // Loading indicator
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child:
                          Lottie.asset('lib/assets/animation_lmek1cqs.json')),
                  const Text(
                    "Welcome to Video player",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Introducing the Ultimate Video Player\nYour Gateway to Seamless Multimedia\nEntertainment!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () => requestPermissionForStorage(context),
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(118, 0, 0, 0),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                        color: Color(0xFF3E008C),
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let’s get started",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 33,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
