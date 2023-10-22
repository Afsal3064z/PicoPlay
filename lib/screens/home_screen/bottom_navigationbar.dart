import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picoplay/screens/Menu_Screen/menu_screen.dart';
import 'package:picoplay/screens/favorite_screen/favorite_screen.dart';
import 'package:picoplay/screens/history_screen/history_screen.dart';
import 'package:picoplay/screens/home_screen/home_screen.dart';
import 'package:picoplay/screens/playList_screen/playlist_screen.dart';

class BottomNavigationDemo extends StatefulWidget {
  const BottomNavigationDemo({Key? key}) : super(key: key);

  @override
  BottomNavigationDemoState createState() => BottomNavigationDemoState();
}

class BottomNavigationDemoState extends State<BottomNavigationDemo> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<String> appBarTitles = ['Home', 'Favorite', 'PlayList', 'History'];

  @override
  void initState() {
    super.initState();

    // Lock the screen orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(CustomPageRoute((context) => const MenuPage()));
          },
          child: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 36,
          ),
        ),
        title: Text(
          appBarTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          HomePage(),
          FavoriteScreen(),
          PlayListScreen(),
          HistoryScreen(),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(162, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 48, 0, 107),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 30,
            ),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.playlist_add,
              size: 30,
            ),
            label: 'PlayList',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: 30,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute(WidgetBuilder builder) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
