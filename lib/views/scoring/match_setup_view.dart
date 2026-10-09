import 'package:flutter/material.dart';
import '../../models/match_outcome.dart';
import '../../models/match_setup.dart';
import 'live_scoring_view.dart';

class MatchSetupView extends StatefulWidget {
  // All optional: filled in when starting a tournament fixture
  final String? teamA;
  final String? teamB;
  final int? overs;
  final int? playersPerSide;
  final String? tournamentName;
  final void Function(MatchOutcome outcome)? onComplete;

  const MatchSetupView({
    super.key,
    this.teamA,
    this.teamB,
    this.overs,
    this.playersPerSide,
    this.tournamentName,
    this.onComplete,
  });

  bool get isFixture => teamA != null && teamB != null;

  @override
  State<MatchSetupView> createState() => _MatchSetupViewState();
}

class _MatchSetupViewState extends State<MatchSetupView> {
  // Steps: 0 = details, 1 = Team A players, 2 = Team B players, 3 = toss & openers
  int _step = 0;
  final _formKey = GlobalKey<FormState>();

  late final _teamA = TextEditingController(text: widget.teamA);
  late final _teamB = TextEditingController(text: widget.teamB);
  late double _overs = (widget.overs ?? 10).toDouble();
  late double _players = (widget.playersPerSide ?? 11).toDouble();

  final List<TextEditingController> _squadA = [];
  final List<TextEditingController> _squadB = [];

  int _tossWinner = 0; // 0 = Team A, 1 = Team B
  bool _tossWinnerBats = true;
  String? _striker;
  String? _nonStriker;
  String? _bowler;

  @override
  void dispose() {
    for (final c in [_teamA, _teamB, ..._squadA, ..._squadB]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Helpers ----------
  String get _nameA => _teamA.text.trim();
  String get _nameB => _teamB.text.trim();
  int get _playerCount => _players.round();

  List<String> _names(List<TextEditingController> squad) =>
      squad.map((c) => c.text.trim()).toList();

  bool get _teamABats => (_tossWinner == 0) == _tossWinnerBats;
  List<String> get _battingSquad =>
      _teamABats ? _names(_squadA) : _names(_squadB);
  List<String> get _bowlingSquad =>
      _teamABats ? _names(_squadB) : _names(_squadA);

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  String _initials(String team) {
    final letters = team
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
    return letters.isEmpty ? 'P' : letters;
  }

  // Keep the number of name boxes equal to players per side
  void _resizeSquad(List<TextEditingController> squad) {
    while (squad.length < _playerCount) {
      squad.add(TextEditingController());
    }
    while (squad.length > _playerCount) {
      squad.removeLast().dispose();
    }
  }

  void _autoFill(List<TextEditingController> squad, String team) {
    final prefix = _initials(team);
    setState(() {
      for (var i = 0; i < squad.length; i++) {
        if (squad[i].text.trim().isEmpty) squad[i].text = '$prefix ${i + 1}';
      }
    });
  }

  void _clearOpeners() {
    _striker = null;
    _nonStriker = null;
    _bowler = null;
  }

  // ---------- Navigation between steps ----------
  void _next() {
    if (!_formKey.currentState!.validate()) return;
    if (_step == 0) {
      _resizeSquad(_squadA);
      _resizeSquad(_squadB);
    }
    if (_step == 2) _clearOpeners(); // names may have changed
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    _startMatch();
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _startMatch() {
    final aBats = _teamABats;
    final setup = MatchSetup(
      battingTeam: aBats ? _nameA : _nameB,
      bowlingTeam: aBats ? _nameB : _nameA,
      battingSquad: _battingSquad,
      bowlingSquad: _bowlingSquad,
      overs: _overs.round(),
      playersPerSide: _playerCount,
      striker: _striker!,
      nonStriker: _nonStriker!,
      bowler: _bowler!,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
                builder: (_) => LiveScoringView(
          setup: setup,
          tournamentName: widget.tournamentName,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  // ---------- Reusable pieces ----------
  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    IconData icon = Icons.shield_outlined,
    bool enabled = true,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? _required,
      ),
    );
  }

  Widget _numberPicker(String label, double value, double min, double max,
      ValueChanged<double>? onChanged) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: text.titleMedium)),
            Text(
              '${value.round()}',
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            IconButton.outlined(
              tooltip: 'Decrease',
              onPressed: onChanged == null || value <= min
                  ? null
                  : () => onChanged(value - 1),
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).round(),
                label: '${value.round()}',
                onChanged: onChanged,
              ),
            ),
            IconButton.outlined(
              tooltip: 'Increase',
              onPressed: onChanged == null || value >= max
                  ? null
                  : () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  FormFieldValidator<String> _playerValidator(
      List<TextEditingController> squad, int index) {
    return (value) {
      final name = value?.trim() ?? '';
      if (name.isEmpty) return 'Enter a name';
      for (var i = 0; i < squad.length; i++) {
        if (i != index &&
            squad[i].text.trim().toLowerCase() == name.toLowerCase()) {
          return 'Name already used in this team';
        }
      }
      return null;
    };
  }

  Widget _dropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged) {
    final safeValue = options.contains(value) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label|$safeValue|${options.join(',')}'),
        initialValue: safeValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final p in options) DropdownMenuItem(value: p, child: Text(p)),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? 'Choose a player' : null,
      ),
    );
  }

  // ---------- The 4 steps ----------
  List<Widget> _detailsStep() {
    final locked = widget.isFixture;
    return [
      _field(_teamA, 'Team A name', enabled: !locked),
      _field(
        _teamB,
        'Team B name',
        enabled: !locked,
        validator: (value) {
          final missing = _required(value);
          if (missing != null) return missing;
          if (value!.trim().toLowerCase() == _nameA.toLowerCase()) {
            return 'Teams need different names';
          }
          return null;
        },
      ),
      const SizedBox(height: 8),
      _numberPicker('Overs per innings', _overs, 5, 50,
          locked ? null : (v) => setState(() => _overs = v)),
      _numberPicker('Players per side', _players, 4, 11,
          locked ? null : (v) => setState(() => _players = v)),
      if (locked)
        Text(
          'Overs and players are set by the tournament.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
    ];
  }

  List<Widget> _squadStep(List<TextEditingController> squad, String team) {
    return [
      Text('Enter all $_playerCount players for $team.'),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => _autoFill(squad, team),
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Fill empty with defaults'),
        ),
      ),
      for (var i = 0; i < squad.length; i++)
        _field(
          squad[i],
          'Player ${i + 1}',
          icon: Icons.person_outline,
          validator: _playerValidator(squad, i),
        ),
    ];
  }

  List<Widget> _tossStep() {
    final batting = _battingSquad;
    final bowling = _bowlingSquad;
    final battingTeam = _teamABats ? _nameA : _nameB;
    final bowlingTeam = _teamABats ? _nameB : _nameA;

    return [
      _heading('Who won the toss?'),
      SegmentedButton<int>(
        segments: [
          ButtonSegment(
            value: 0,
            label: Text(_nameA, overflow: TextOverflow.ellipsis),
          ),
          ButtonSegment(
            value: 1,
            label: Text(_nameB, overflow: TextOverflow.ellipsis),
          ),
        ],
        selected: {_tossWinner},
        onSelectionChanged: (s) => setState(() {
          _tossWinner = s.first;
          _clearOpeners();
        }),
      ),
      _heading('They chose to'),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('Bat'),
            icon: Icon(Icons.sports_cricket),
          ),
          ButtonSegment(
            value: false,
            label: Text('Bowl'),
            icon: Icon(Icons.sports_baseball),
          ),
        ],
        selected: {_tossWinnerBats},
        onSelectionChanged: (s) => setState(() {
          _tossWinnerBats = s.first;
          _clearOpeners();
        }),
      ),
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text('$battingTeam bat first'),
        ),
      ),
      _heading('$battingTeam openers'),
      _dropdown(
        'Batter on strike',
        _striker,
        batting,
        (v) => setState(() {
          _striker = v;
          if (_nonStriker == v) _nonStriker = null;
        }),
      ),
      _dropdown(
        'Non-striker',
        _nonStriker,
        batting.where((p) => p != _striker).toList(),
        (v) => setState(() => _nonStriker = v),
      ),
      _heading('$bowlingTeam opening bowler'),
      _dropdown(
        'Bowler',
        _bowler,
        bowling,
        (v) => setState(() => _bowler = v),
      ),
    ];
  }

  // ---------- Screen ----------
  @override
  Widget build(BuildContext context) {
    final stepTitle = switch (_step) {
      1 => '$_nameA players',
      2 => '$_nameB players',
      3 => 'Toss & openers',
      _ => 'Match details',
    };

    final stepContent = switch (_step) {
      1 => _squadStep(_squadA, _nameA),
      2 => _squadStep(_squadB, _nameB),
      3 => _tossStep(),
      _ => _detailsStep(),
    };

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back(); // phone back button goes to the previous step
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isFixture ? 'Tournament match' : 'New match'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LinearProgressIndicator(value: (_step + 1) / 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          stepTitle,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('Step ${_step + 1} of 4'),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: stepContent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      if (_step > 0) ...[
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _back,
                              child: const Text('Back'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _next,
                            child: Text(
                                _step == 3 ? 'Start match' : 'Continue'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}