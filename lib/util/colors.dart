import 'package:flutter/material.dart';

class MyColors {
  /// White.
  static Color get white => Colors.white;

  static Color _tColor = const Color(0xff53a99a);

  /// Theme color.
  static Color get themeColor => _tColor;

  /// Sets theme color.
  static set setThemeColor(Color color) {
    _tColor = color;
  }

  /// Dark grey.
  static Color get darkGrey => Colors.grey[900]!;

  /// A list of color choices to be applied as a theme.
  static List<Color> themeChoices = [
    const Color(0xff53a99a),
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.deepOrange,
    Colors.indigoAccent,
    Colors.amber,
    Colors.cyan,
    Colors.pinkAccent,
    Colors.lightGreen,
    Colors.deepPurple,
    const Color.fromARGB(255, 255, 102, 102),
  ];
}
