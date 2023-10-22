/// This is the custom widgets for the menu///
import 'package:flutter/material.dart';

/// This the custome tile  class for the  info section ///

class CustomTile extends StatelessWidget {
  const CustomTile(
      {super.key,
      required this.text,
      required this.icon,
      required this.customTap});
  final String text;
  final IconData icon;
  final Widget customTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
//////////////////////////////////////////////////////////////////////////////////
      ///This navigation is used to navigate to different pages according to the///
      ///the custome tile//
///////////////////////////////////////////////////////////////////////////////////
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => customTap));
      },
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 48, 0, 107),
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
// This is a sized box to reuse to get a simple space between the widgets
class GapBetween extends StatelessWidget {
  const GapBetween({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}
