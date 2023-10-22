// This is the privacy policy page of the app :

import 'package:flutter/material.dart';
import 'package:picoplay/screens/Menu_Screen/privacy_policy_screen/pirvacy_policy_custom_widgets.dart';
import 'package:picoplay/screens/home_screen/home_screen.dart';
import 'package:picoplay/theme_data/theme_colors.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
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
          "Privacy Policy",
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
/////////////////////////////////////////////////////////////////////////
        /// custome list view is been called ///
        child: const PrivacyPolicyCustomListView(),
      ),
    );
  }
}
