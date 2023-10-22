// This is the settings screen of the app :

import 'package:flutter/material.dart';
import 'package:picoplay/screens/home_screen/home_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          "Settings",
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
          child: ListView(
            children: const [],
          )),
    );
  }
}
