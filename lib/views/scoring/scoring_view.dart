import 'package:flutter/material.dart';
import '../app_drawer.dart'; 

class ScoringView extends StatelessWidget {
  const ScoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score a Match')),
       drawer: const AppDrawer(), 
      body: const Center(child: Text('Live scoring goes here')),
    );
  }
}