import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/tournament_view_model.dart';
import 'tournament_detail_view.dart';

class CreateTournamentView extends StatefulWidget {
  const CreateTournamentView({super.key});

  @override
  State<CreateTournamentView> createState() => _CreateTournamentViewState();
}

class _CreateTournamentViewState extends State<CreateTournamentView> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();
  final List<String> _teams = [];
  int _overs = 10;
  int _players = 8;
  String? _nameError;
  String? _teamError;

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  void _addTeam() {
    final name = _teamController.text.trim();
    if (name.isEmpty) return;
    if (_teams.any((t) => t.toLowerCase() == name.toLowerCase())) {
      setState(() => _teamError = 'That team is already added');
      return;
    }
    setState(() {
      _teams.add(name);
      _teamController.clear();
      _teamError = null;
    });
  }

  void _next() {
    if (_step == 0) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = 'Give your tournament a name');
        return;
      }
      setState(() {
        _nameError = null;
        _step = 1;
      });
    } else if (_step == 1) {
      if (_teams.length < 3) {
        setState(() => _teamError = 'Add at least 3 teams');
        return;
      }
      setState(() {
        _teamError = null;
        _step = 2;
      });
    } else {
      final tournament = context.read<TournamentViewModel>().createTournament(
            name: _nameController.text.trim(),
            overs: _overs,
            playersPerSide: _players,
            teams: _teams,
          );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TournamentDetailView(tournamentId: tournament.id),
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _choice(List<int> options, int selected, ValueChanged<int> onPick) {
    return SegmentedButton<int>(
      segments: [
        for (final o in options) ButtonSegment(value: o, label: Text('$o')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onPick(s.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = TournamentViewModel.generateFixtures(_teams);

    return Scaffold(
      appBar: AppBar(title: const Text('New tournament')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _next,
        onStepCancel: _back,
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(_step == 2 ? 'Create tournament' : 'Next'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: details.onStepCancel,
                child: Text(_step == 0 ? 'Cancel' : 'Back'),
              ),
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Details'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Tournament name',
                    border: const OutlineInputBorder(),
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Overs per innings'),
                const SizedBox(height: 8),
                _choice([5, 10, 20], _overs,
                    (v) => setState(() => _overs = v)),
                const SizedBox(height: 16),
                const Text('Players per side'),
                const SizedBox(height: 8),
                _choice([6, 8, 11], _players,
                    (v) => setState(() => _players = v)),
              ],
            ),
          ),
          Step(
            title: const Text('Teams'),
            subtitle: Text('${_teams.length} added'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _teamController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Team name',
                          border: const OutlineInputBorder(),
                          errorText: _teamError,
                        ),
                        onSubmitted: (_) => _addTeam(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addTeam,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add team',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._teams.map(
                  (team) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(team),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove',
                      onPressed: () => setState(() => _teams.remove(team)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Fixtures'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${preview.length} matches. Every team plays '
                    'each other once.'),
                const SizedBox(height: 8),
                for (final (i, f) in preview.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Text('${i + 1}.'),
                    title: Text('${f.teamA}  v  ${f.teamB}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}