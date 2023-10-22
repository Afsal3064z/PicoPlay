

import 'package:flutter/material.dart';

/// This is the custom text widget used in the privacy policy screen///
class CustomText extends StatelessWidget {
  const CustomText(
      {super.key, required this.text, required this.size, this.isBold = false});
  final String text;
  final double size;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}