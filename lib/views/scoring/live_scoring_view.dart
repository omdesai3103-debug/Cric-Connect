import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ball.dart';
import '../../models/match_outcome.dart';
import '../../models/match_setup.dart';
import '../../viewmodels/scoring_view_model.dart';
import '../../models/match_record.dart';
import '../../viewmodels/match_history_view_model.dart';

class LiveScoringView extends StatelessWidget {
  final MatchSetup setup;
  final String? tournamentName;
  final void Function(MatchOutcome outcome)? onComplete;
  const LiveScoringView({
    super.key,
    required this.setup,
    this.tournamentName,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScoringViewModel(setup),
      child: _LiveScoringScreen(
        tournamentName: tournamentName,
        onComplete: onComplete,
      ),
    );
  }
}

class _LiveScoringScreen extends StatelessWidget {
  final String? tournamentName;
  final void Function(MatchOutcome outcome)? onComplete;
  const _LiveScoringScreen({this.tournamentName, this.onComplete});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScoringViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (vm.isMatchOver) {
          _finish(context, vm); // back button also saves the result
          return;
        }
        final leave = await _confirmLeave(context);
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              vm.isMatchOver ? 'Match result' : '${vm.battingTeam} batting'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ScoreHeader(vm: vm),
                      const SizedBox(height: 12),
                      _statusCard(context, vm),
                      _PlayersCard(vm: vm),
                      const SizedBox(height: 16),
                      _ThisOver(balls: vm.thisOver),
                    ],
                  ),
                ),
              ),
              _scoringPad(context, vm),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Innings break / result card ----------
  Widget _statusCard(BuildContext context, ScoringViewModel vm) {
    final title = Theme.of(context).textTheme.titleLarge;

    if (vm.isInningsBreak) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          color: Colors.amber.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Innings break', style: title),
                const SizedBox(height: 4),
                Text(
                  '${vm.battingTeam} ${vm.score} (${vm.overs} ov)\n'
                  '${vm.bowlingTeam} need ${vm.runs + 1} to win',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _startSecondInnings(context, vm),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Start 2nd innings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (vm.isMatchOver) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, size: 40),
                Text(
                  vm.resultText,
                  textAlign: TextAlign.center,
                  style: title?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vm.firstInningsSummary}\n'
                  '${vm.battingTeam} ${vm.score} (${vm.overs} ov)',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _finish(context, vm),
                  child: Text(onComplete == null ? 'Done' : 'Save result'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

   void _finish(BuildContext context, ScoringViewModel vm) {
    context.read<MatchHistoryViewModel>().add(MatchRecord(
          outcome: vm.outcome,
          overs: vm.setup.overs,
          playedOn: DateTime.now(),
          tournamentName: tournamentName,
        ));
    onComplete?.call(vm.outcome);
    Navigator.pop(context);
  }

  // ---------- Dialogs ----------
  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave this match?'),
        content: const Text('The score will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  // One tap picks a player. Returns null if the scorer cancels.
  Future<String?> _pickPlayer(
    BuildContext context,
    String title,
    List<String> options, {
    String cancelLabel = 'Undo last ball',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.only(top: 12),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final p in options)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(p),
                  onTap: () => Navigator.pop(dialogContext, p),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _startSecondInnings(
      BuildContext context, ScoringViewModel vm) async {
    final chasingSquad = vm.bowlingSquad; // bowled first, bats now
    final fieldingSquad = vm.battingSquad; // batted first, bowls now

    final striker = await _pickPlayer(
        context, '${vm.bowlingTeam}: batter on strike', chasingSquad,
        cancelLabel: 'Cancel');
    if (striker == null || !context.mounted) return;

    final nonStriker = await _pickPlayer(context, 'Non-striker',
        chasingSquad.where((p) => p != striker).toList(),
        cancelLabel: 'Cancel');
    if (nonStriker == null || !context.mounted) return;

    final bowler = await _pickPlayer(
        context, '${vm.battingTeam}: opening bowler', fieldingSquad,
        cancelLabel: 'Cancel');
    if (bowler == null) return;

    vm.startSecondInnings(
        striker: striker, nonStriker: nonStriker, bowler: bowler);
  }

  // ---------- Recording a ball + follow-up prompts ----------
  Future<void> _record(BuildContext context,
      {int runs = 0, Extra extra = Extra.none, bool isWicket = false}) async {
    final vm = context.read<ScoringViewModel>();
    vm.recordBall(runs: runs, extra: extra, isWicket: isWicket);

    if (vm.needsNewBatter) {
      final name = await _pickPlayer(
          context, 'Wicket! Who comes in?', vm.availableBatters);
      if (name == null) {
        vm.undo();
        return;
      }
      vm.setNewBatter(name);
    }

    if (!context.mounted) return;

    if (vm.needsNewBowler) {
      final name = await _pickPlayer(
          context, 'Over complete. Next bowler?', vm.availableBowlers);
      if (name == null) {
        vm.undo();
        return;
      }
      vm.setNewBowler(name);
    }
  }

  // ---------- The big buttons (bottom = thumb zone) ----------
  Widget _scoringPad(BuildContext context, ScoringViewModel vm) {
    final enabled = vm.canScore;

    VoidCallback? run(int r) =>
        enabled ? () => _record(context, runs: r) : null;

    Widget key(String label, VoidCallback? onTap,
        {Color? color, Color? textColor, int flex = 1}) {
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 64,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: textColor,
                textStyle:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(label),
            ),
          ),
        ),
      );
    }

    final runColor = Colors.grey.shade200;
    const runText = Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          Row(children: [
            key('0', run(0), color: runColor, textColor: runText),
            key('1', run(1), color: runColor, textColor: runText),
            key('2', run(2), color: runColor, textColor: runText),
            key('3', run(3), color: runColor, textColor: runText),
          ]),
          Row(children: [
            key('4', run(4), color: Colors.green.shade700),
            key('6', run(6), color: Colors.green.shade700),
            key('Wd', enabled ? () => _record(context, extra: Extra.wide) : null,
                color: Colors.orange.shade800),
            key('Nb',
                enabled ? () => _record(context, extra: Extra.noBall) : null,
                color: Colors.orange.shade800),
          ]),
          Row(children: [
            key('OUT', enabled ? () => _record(context, isWicket: true) : null,
                color: Colors.red.shade700, flex: 2),
            key('UNDO', vm.canUndo ? vm.undo : null,
                color: Colors.blueGrey.shade600, flex: 2),
          ]),
        ],
      ),
    );
  }
}

// ---------- Small display pieces ----------
class _ScoreHeader extends StatelessWidget {
  final ScoringViewModel vm;
  const _ScoreHeader({required this.vm});

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
            Text(vm.innings == 1 ? '1st innings' : '2nd innings',
                style: base.copyWith(fontSize: 14)),
            Text(vm.score,
                style: base.copyWith(fontSize: 56, fontWeight: FontWeight.bold)),
            Text('Overs ${vm.overs} / ${vm.setup.overs}   •   CRR ${vm.runRate}',
                style: base.copyWith(fontSize: 16)),
            if (vm.target != null && !vm.isMatchOver) ...[
              const SizedBox(height: 8),
              Text(
                'Target ${vm.target}  •  ${vm.chaseText}',
                style: base.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayersCard extends StatelessWidget {
  final ScoringViewModel vm;
  const _PlayersCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(context, '${vm.striker} *', vm.batterFigures(vm.striker),
                bold: true),
            const SizedBox(height: 8),
            _row(context, vm.nonStriker, vm.batterFigures(vm.nonStriker)),
            const Divider(height: 24),
            _row(context, 'Bowler: ${vm.bowler}', ''),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String name, String figures,
      {bool bold = false}) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Row(
      children: [
        Expanded(
          child: Text(name, style: style, overflow: TextOverflow.ellipsis),
        ),
        Text(figures, style: style),
      ],
    );
  }
}

class _ThisOver extends StatelessWidget {
  final List<Ball> balls;
  const _ThisOver({required this.balls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This over', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (balls.isEmpty)
          const Text('No balls yet')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: balls.map((b) => _BallChip(ball: b)).toList(),
          ),
      ],
    );
  }
}

class _BallChip extends StatelessWidget {
  final Ball ball;
  const _BallChip({required this.ball});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground = Colors.white;

    if (ball.isWicket) {
      background = Colors.red.shade700;
    } else if (ball.runs == 4 || ball.runs == 6) {
      background = Colors.green.shade700;
    } else if (!ball.isLegal) {
      background = Colors.orange.shade800;
    } else {
      background = Colors.grey.shade300;
      foreground = Colors.black87;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: background,
      child: Text(
        ball.label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}