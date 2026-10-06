import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/main_shell.dart';

void main() {
  runApp(const CricConnectApp());
}

class CricConnectApp extends StatelessWidget {
  const CricConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cric-Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}