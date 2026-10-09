import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tournament.dart';
import '../../viewmodels/tournament_view_model.dart';
import '../scoring/match_setup_view.dart';

class TournamentDetailView extends StatelessWidget {
  final String tournamentId;
  const TournamentDetailView({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentViewModel>();
    final tournament = vm.byId(tournamentId);
    final standings = vm.standings(tournament);
    final champion = tournament.isComplete ? standings.first.team : null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tournament.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Fixtures'),
              Tab(text: 'Points table'),
              Tab(text: 'Teams'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FixturesTab(tournament: tournament, champion: champion),
            _PointsTableTab(standings: standings),
            _TeamsTab(tournament: tournament),
          ],
        ),
      ),
    );
  }
}

class _FixturesTab extends StatelessWidget {
  final Tournament tournament;
  final String? champion;
  const _FixturesTab({required this.tournament, this.champion});

  void _startFixture(BuildContext context, Fixture fixture) {
    final vm = context.read<TournamentViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchSetupView(
          teamA: fixture.teamA,
          teamB: fixture.teamB,
          overs: tournament.overs,
          playersPerSide: tournament.playersPerSide,
          tournamentName: tournament.name,
          onComplete: (outcome) =>
              vm.recordOutcome(tournament.id, fixture.id, outcome),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (champion != null)
          Card(
            color: Colors.amber.shade100,
            child: ListTile(
              leading: const Icon(Icons.emoji_events, size: 36),
              title: const Text('Champion'),
              subtitle: Text(
                champion!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${tournament.playedCount} of ${tournament.fixtures.length} played  •  '
            '${tournament.overs} overs  •  ${tournament.playersPerSide}-a-side',
          ),
        ),
        for (final (i, f) in tournament.fixtures.indexed)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text('${f.teamA}  v  ${f.teamB}'),
              subtitle: Text(f.result ?? 'Not played yet'),
              trailing: f.isPlayed
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : FilledButton.tonal(
                      onPressed: () => _startFixture(context, f),
                      child: const Text('Start'),
                    ),
            ),
          ),
      ],
    );
  }
}

class _PointsTableTab extends StatelessWidget {
  final List<TeamStanding> standings;
  const _PointsTableTab({required this.standings});

  String _nrr(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(3)}';

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.bold);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Team')),
              DataColumn(label: Text('P'), numeric: true),
              DataColumn(label: Text('W'), numeric: true),
              DataColumn(label: Text('L'), numeric: true),
              DataColumn(label: Text('T'), numeric: true),
              DataColumn(label: Text('Pts'), numeric: true),
              DataColumn(label: Text('NRR'), numeric: true),
            ],
            rows: [
              for (final (i, s) in standings.indexed)
                DataRow(cells: [
                  DataCell(Text('${i + 1}')),
                  DataCell(Text(s.team, style: i == 0 ? bold : null)),
                  DataCell(Text('${s.played}')),
                  DataCell(Text('${s.won}')),
                  DataCell(Text('${s.lost}')),
                  DataCell(Text('${s.tied}')),
                  DataCell(Text('${s.points}', style: bold)),
                  DataCell(Text(_nrr(s.netRunRate))),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Win = 2 points, tie = 1 point. Teams level on points are '
          'separated by net run rate (NRR).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TeamsTab extends StatelessWidget {
  final Tournament tournament;
  const _TeamsTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final matchesEach = tournament.teams.length - 1;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final team in tournament.teams)
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(team),
              subtitle: Text('$matchesEach matches in this tournament'),
            ),
          ),
      ],
    );
  }
}