import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cricket_match.dart';
import '../../repositories/match_repository.dart';
import '../../viewmodels/home_feed_view_model.dart';
import '../app_drawer.dart';
import 'match_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeFeedViewModel(MatchRepository())..loadFeed(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cric-Connect')),
        drawer: const AppDrawer(),
        body: Consumer<HomeFeedViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && !vm.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: vm.loadFeed,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _section(context, 'Live now', vm.live),
                  _section(context, 'Upcoming', vm.upcoming),
                  _section(context, 'Recent results', vm.completed),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, String title, List<CricketMatch> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...matches.map((m) => MatchCard(match: m)),
      ],
    );
  }
}