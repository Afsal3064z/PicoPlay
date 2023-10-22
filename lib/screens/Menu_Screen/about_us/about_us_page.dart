// This is the About Us page of the app :
import 'package:flutter/material.dart';
import 'package:picoplay/screens/Menu_Screen/about_us/about_us_custom_widget.dart';
import 'package:picoplay/screens/home_screen/home_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
          child: const Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 36,
          ),
        ),
        title: const Text(
          "About Us",
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
        child: const AboutUsCustomListView(),
      ),
    );
  }
}
