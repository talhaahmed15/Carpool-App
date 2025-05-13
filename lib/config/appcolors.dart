import 'package:flutter/material.dart';

class AppColors {
  static Color backgroundColor = Colors.white;
  static Color? blackColor = Colors.grey[800];
  static Color? whiteColor = Colors.white;
  // static Color grey = const Color(0xFFeaeaea);
  static Color grey = const Color(0xFFF3F3F3);

  static List<Color> appThemeLow = [
    Colors.red[300]!, // Lighter shade of red
    Colors.blue[300]!, // Lighter shade of blue
    const Color(0xFFFF6666), // Lighter shade of the custom color (0xFFE30000)
  ];

  static List<Color> appTheme = [
    Colors.red,
    Colors.blue,
    const Color(0xFFE30000),
  ];
}
