import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tab_navigation.dart';
import 'career/my_career_view.dart';
import 'home/home_view.dart';
import 'scoring/scoring_view.dart';
import 'tournaments/tournaments_view.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    ScoringView(),
    TournamentsView(),
    MyCareerView(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<TabNavigation>();

    return Scaffold(
      body: _pages[tabs.index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabs.index,
        onDestinationSelected: tabs.go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_cricket_outlined),
            selectedIcon: Icon(Icons.sports_cricket),
            label: 'Score',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'My Career',
          ),
        ],
      ),
    );
  }
}