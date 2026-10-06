import 'package:flutter/material.dart';

class ScoringView extends StatelessWidget {
  const ScoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score a Match')),
      body: const Center(child: Text('Live scoring goes here')),
    );
  }
}