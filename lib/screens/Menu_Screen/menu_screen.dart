/// This is the menu for the app///

import 'package:flutter/material.dart';
import 'package:picoplay/screens/Menu_Screen/about_us/about_us_page.dart';
import 'package:picoplay/screens/Menu_Screen/menu_custom_tile.dart';
import 'package:picoplay/screens/Menu_Screen/privacy_policy_screen/privacy_policy.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 36,
          ),
        ),
        title: const Text(
          "Menu",
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
          children: const [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
//////////////////////////////////////////////////////////////////////////
                  ///The custom tile is been called///
                  CustomTile(
                      text: "Privacy",
                      icon: Icons.privacy_tip,
                      customTap: PrivacyPolicy()),
                  GapBetween(),
                  CustomTile(
                    text: "About Us",
                    icon: Icons.info,
                    customTap: AboutUsPage(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
