import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_record.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/match_history_view_model.dart';
import '../../viewmodels/tournament_view_model.dart';
import '../app_drawer.dart';
import '../tournaments/tournament_detail_view.dart';

class MyCareerView extends StatelessWidget {
  const MyCareerView({super.key});

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _emptyNote(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final tournamentVm = context.watch<TournamentViewModel>();
    final history = context.watch<MatchHistoryViewModel>();

    final tournaments = tournamentVm.tournaments;
    final matches = history.records;
    final completed = tournaments.where((t) => t.isComplete).length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Career')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            name: auth.isLoggedIn ? auth.userName! : 'Guest Player',
            matches: matches.length,
            tournaments: tournaments.length,
            completed: completed,
          ),
          _sectionTitle(context, 'My tournaments'),
          if (tournaments.isEmpty)
            _emptyNote('Create a tournament from the Tournaments tab.')
          else
            for (final t in tournaments)
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
                  subtitle: Text(t.isComplete
                      ? 'Champion: ${tournamentVm.standings(t).first.team}'
                      : '${t.playedCount}/${t.fixtures.length} matches played'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentDetailView(tournamentId: t.id),
                    ),
                  ),
                ),
              ),
          _sectionTitle(context, 'Matches played'),
          if (matches.isEmpty)
            _emptyNote('Matches you score will appear here.')
          else
            for (final m in matches) _MatchRecordCard(record: m),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final int matches;
  final int tournaments;
  final int completed;

  const _HeaderCard({
    required this.name,
    required this.matches,
    required this.tournaments,
    required this.completed,
  });

  Widget _stat(String value, String label, TextStyle base) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: base.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: base.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(color: colors.onPrimary);

    return Card(
      color: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.onPrimary,
              child: Icon(Icons.person, size: 36, color: colors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: base.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _stat('$matches', 'Matches', base),
                _stat('$tournaments', 'Tournaments', base),
                _stat('$completed', 'Completed', base),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchRecordCard extends StatelessWidget {
  final MatchRecord record;
  const _MatchRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final d = record.playedOn;
    final isFriendly = record.tournamentName == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFriendly
                          ? Colors.blue.shade50
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.tournamentName ?? 'Friendly',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${d.day}/${d.month}/${d.year}', style: text.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(record.firstSummary, style: text.titleMedium),
            Text(record.secondSummary, style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              record.outcome.result,
              style: text.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}