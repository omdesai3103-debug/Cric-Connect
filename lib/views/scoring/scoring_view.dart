import 'package:flutter/material.dart';
import '../app_drawer.dart';
import 'match_setup_view.dart';

class ScoringView extends StatelessWidget {
  const ScoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score a Match')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_cricket, size: 80),
            const SizedBox(height: 16),
            Text(
              'Score a quick match',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'No club or registration needed.\nSet up in under a minute.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MatchSetupView()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Start new match'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}