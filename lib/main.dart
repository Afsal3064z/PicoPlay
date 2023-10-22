import 'package:flutter/material.dart';
import 'package:picoplay/screens/home_screen/bottom_navigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:picoplay/screens/landing_page/landing_page.dart';

Future<void> main() async {
  /////////////////////////////////////////////////////////////////
  ///This the intialiastion of the shared preference for the Introductiong page///
  ///This is the function to check the app is openned for the first time///
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isIntroductionShown = prefs.getBool('isIntroductionShown') ?? false;
  runApp(MyApp(
    isIntroductionShown: isIntroductionShown,
  ));
}

//////////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  final bool isIntroductionShown;
  const MyApp({
    super.key,
    this.isIntroductionShown = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,

      ///Check the bool value in the shared preference to navigate to the corresponding page///
      home: isIntroductionShown
          ? const BottomNavigationDemo()
          : const LandingPage(),
    );
  }
}

/////////////////////////////////////////////////////////
