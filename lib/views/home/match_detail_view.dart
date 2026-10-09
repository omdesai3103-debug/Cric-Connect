import 'package:flutter/material.dart';
import '../../models/cricket_match.dart';
import '../../models/match_detail.dart';
import '../../repositories/match_repository.dart';
import '../../viewmodels/match_detail_view_model.dart';

class MatchDetailView extends StatelessWidget {
  final CricketMatch match;
  const MatchDetailView({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final vm = MatchDetailViewModel(match, MatchRepository());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${match.teamA} v ${match.teamB}',
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: vm.overviewLabel),
              const Tab(text: 'Scorecard'),
              const Tab(text: 'Squads'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(vm: vm),
            _ScorecardTab(innings: vm.detail.innings),
            _SquadsTab(vm: vm),
          ],
        ),
      ),
    );
  }
}

// ---------- Tab 1: Live / Summary / Info ----------
class _OverviewTab extends StatelessWidget {
  final MatchDetailViewModel vm;
  const _OverviewTab({required this.vm});

  static const _bold = TextStyle(fontWeight: FontWeight.bold);

  Widget _scoreLine(String team, String? score, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 17),
          ),
        ),
        Text(
          score ?? '',
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _liveSection() {
    final bowler = vm.currentBowler;
    return [
      const _SectionTitle('Batting now'),
      Card(
        child: Column(
          children: [
            for (final b in vm.battingNow)
              ListTile(
                leading: const Icon(Icons.sports_cricket),
                title: Text(b.name),
                trailing: Text('${b.runs} (${b.balls})', style: _bold),
              ),
          ],
        ),
      ),
      if (bowler != null) ...[
        const _SectionTitle('Bowling'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sports_baseball),
            title: Text(bowler.name),
            trailing: Text(
              '${bowler.wickets}-${bowler.runs} (${bowler.overs})',
              style: _bold,
            ),
          ),
        ),
      ],
      const _SectionTitle('Recent balls'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final b in vm.detail.recentBalls) _BallBubble(label: b),
        ],
      ),
    ];
  }

  List<Widget> _summarySection() {
    final bat = vm.topScorer;
    final bowl = vm.bestBowler;
    return [
      const _SectionTitle('Top performers'),
      if (bat != null)
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.sports_cricket)),
            title: Text(bat.name),
            subtitle: const Text('Top scorer'),
            trailing: Text('${bat.runs} (${bat.balls})', style: _bold),
          ),
        ),
      if (bowl != null)
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.sports_baseball)),
            title: Text(bowl.name),
            subtitle: const Text('Best bowling'),
            trailing: Text('${bowl.wickets}/${bowl.runs}', style: _bold),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final m = vm.match;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: colors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _scoreLine(m.teamA, m.scoreA, colors.onPrimary),
                const SizedBox(height: 8),
                _scoreLine(m.teamB, m.scoreB ?? (vm.isLive ? 'Yet to bat' : ''),
                    colors.onPrimary),
                const SizedBox(height: 12),
                Text(
                  vm.statusLine,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(m.venue),
        ),
        if (vm.isLive) ..._liveSection(),
        if (vm.isCompleted) ..._summarySection(),
        if (vm.isUpcoming)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  'The scorecard will appear here once the match starts.'),
            ),
          ),
      ],
    );
  }
}

// ---------- Tab 2: Scorecard ----------
class _ScorecardTab extends StatelessWidget {
  final List<InningsCard> innings;
  const _ScorecardTab({required this.innings});

  @override
  Widget build(BuildContext context) {
    if (innings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No scorecard yet. Check back once the match starts.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [for (final inn in innings) _InningsSection(innings: inn)],
    );
  }
}

class _InningsSection extends StatelessWidget {
  final InningsCard innings;
  const _InningsSection({required this.innings});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const bold = TextStyle(fontWeight: FontWeight.bold);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    innings.team,
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  innings.score,
                  style:
                      text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 14,
                horizontalMargin: 4,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Batter')),
                  DataColumn(label: Text('R'), numeric: true),
                  DataColumn(label: Text('B'), numeric: true),
                  DataColumn(label: Text('4s'), numeric: true),
                  DataColumn(label: Text('6s'), numeric: true),
                  DataColumn(label: Text('SR'), numeric: true),
                ],
                rows: [
                  for (final b in innings.batting)
                    DataRow(cells: [
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(b.name, style: bold),
                          Text(b.dismissal, style: text.bodySmall),
                        ],
                      )),
                      DataCell(Text('${b.runs}', style: bold)),
                      DataCell(Text('${b.balls}')),
                      DataCell(Text('${b.fours}')),
                      DataCell(Text('${b.sixes}')),
                      DataCell(Text(b.strikeRate)),
                    ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text('Extras: ${innings.extras}'),
            ),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                horizontalMargin: 4,
                columns: const [
                  DataColumn(label: Text('Bowler')),
                  DataColumn(label: Text('O'), numeric: true),
                  DataColumn(label: Text('R'), numeric: true),
                  DataColumn(label: Text('W'), numeric: true),
                  DataColumn(label: Text('Econ'), numeric: true),
                ],
                rows: [
                  for (final b in innings.bowling)
                    DataRow(cells: [
                      DataCell(Text(b.name, style: bold)),
                      DataCell(Text(b.overs)),
                      DataCell(Text('${b.runs}')),
                      DataCell(Text('${b.wickets}', style: bold)),
                      DataCell(Text(b.economy)),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Tab 3: Squads ----------
class _SquadsTab extends StatelessWidget {
  final MatchDetailViewModel vm;
  const _SquadsTab({required this.vm});

  Widget _squadCard(BuildContext context, String team, List<String> players) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              team,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          for (final (i, p) in players.indexed)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
              ),
              title: Text(p),
              trailing: i == 0
                  ? const _RoleTag('C')
                  : i == 1
                      ? const _RoleTag('WK')
                      : null,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vm.isUpcoming)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Probable squads',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        _squadCard(context, vm.match.teamA, vm.detail.squadA),
        _squadCard(context, vm.match.teamB, vm.detail.squadB),
      ],
    );
  }
}

// ---------- Small shared pieces ----------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _RoleTag extends StatelessWidget {
  final String label;
  const _RoleTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _BallBubble extends StatelessWidget {
  final String label;
  const _BallBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    Color background = Colors.grey.shade300;
    Color foreground = Colors.black87;

    if (label == 'W') {
      background = Colors.red.shade700;
      foreground = Colors.white;
    } else if (label == '4' || label == '6') {
      background = Colors.green.shade700;
      foreground = Colors.white;
    } else if (label == 'Wd' || label == 'Nb') {
      background = Colors.orange.shade800;
      foreground = Colors.white;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: background,
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}