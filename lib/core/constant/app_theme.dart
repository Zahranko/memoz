import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Color.fromRGBO(250, 248, 248, 0.7),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: Colors.orange.withAlpha((0.2 * 255).round()),
      backgroundColor: Colors.grey.shade200,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.grey.withAlpha((0.2 * 255).round()),
    ),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Color.fromRGBO(250, 248, 248, 0.9),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((0.2 * 255).round()),
        spreadRadius: 2,
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
