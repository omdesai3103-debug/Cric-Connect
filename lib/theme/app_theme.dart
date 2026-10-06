import 'package:flutter/material.dart';

class AppTheme {
  static const Color pitchGreen = Color(0xFF1B5E20);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: pitchGreen),
    scaffoldBackgroundColor: Colors.white,
  );
}