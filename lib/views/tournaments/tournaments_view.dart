import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/tournament_view_model.dart';
import '../app_drawer.dart';
import 'create_tournament_view.dart';
import 'tournament_detail_view.dart';

class TournamentsView extends StatelessWidget {
  const TournamentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTournamentView()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: vm.tournaments.isEmpty
          ? const Center(child: Text('No tournaments yet'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final t in vm.tournaments)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(t.isComplete
                            ? Icons.emoji_events
                            : Icons.sports_cricket),
                      ),
                      title: Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${t.teams.length} teams  •  ${t.overs} overs  •  '
                        '${t.playedCount}/${t.fixtures.length} played',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TournamentDetailView(tournamentId: t.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}