import 'package:flutter/material.dart';
import '../app_drawer.dart'; 

class TournamentsView extends StatelessWidget {
  const TournamentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
       drawer: const AppDrawer(), 
      body: const Center(child: Text('Fixtures and points table')),
    );
  }
}