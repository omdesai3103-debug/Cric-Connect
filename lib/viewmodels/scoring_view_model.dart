import 'package:flutter/foundation.dart';
import '../models/ball.dart';
import '../models/match_outcome.dart';
import '../models/match_setup.dart';

class ScoringViewModel extends ChangeNotifier {
  final MatchSetup setup;

  ScoringViewModel(this.setup)
      : _battingTeam = setup.battingTeam,
        _bowlingTeam = setup.bowlingTeam,
        _battingSquad = setup.battingSquad,
        _bowlingSquad = setup.bowlingSquad,
        _striker = setup.striker,
        _nonStriker = setup.nonStriker,
        _bowler = setup.bowler;

  // ---------- Match-level state ----------
  int _innings = 1;
  int? _target;
  String? _firstInningsSummary;
  String _battingTeam;
  String _bowlingTeam;
  List<String> _battingSquad;
  List<String> _bowlingSquad;
  int _firstRuns = 0;
  int _firstBalls = 0;

  // ---------- Innings-level state ----------
  int _runs = 0;
  int _wickets = 0;
  int _legalBalls = 0;
  String _striker;
  String _nonStriker;
  String _bowler;
  String? _outBatter;
  Set<String> _dismissed = {};
  bool _needsNewBatter = false;
  bool _needsNewBowler = false;
  List<Ball> _balls = [];
  Map<String, int> _batterRuns = {};
  Map<String, int> _batterBalls = {};

  // Saved copies of the state before each ball, so Undo can restore them
  final List<_Snapshot> _history = [];

  // ---------- What the screen reads ----------
  String get battingTeam => _battingTeam;
  String get bowlingTeam => _bowlingTeam;
  List<String> get battingSquad => _battingSquad;
  List<String> get bowlingSquad => _bowlingSquad;
  int get innings => _innings;
  int? get target => _target;
  String? get firstInningsSummary => _firstInningsSummary;
  int get runs => _runs;
  int get maxWickets => setup.playersPerSide - 1;

  // Players who haven't batted yet and aren't at the crease
  List<String> get availableBatters => _battingSquad
      .where((p) =>
          !_dismissed.contains(p) && p != _striker && p != _nonStriker)
      .toList();

  // Same bowler can't bowl two overs in a row
  List<String> get availableBowlers =>
      _bowlingSquad.where((p) => p != _bowler).toList();

  String get score => '$_runs/$_wickets';
  String get overs => '${_legalBalls ~/ 6}.${_legalBalls % 6}';
  String get runRate => _legalBalls == 0
      ? '0.00'
      : (_runs * 6 / _legalBalls).toStringAsFixed(2);
  String get striker => _striker;
  String get nonStriker => _nonStriker;
  String get bowler => _bowler;
  bool get needsNewBatter => _needsNewBatter;
  bool get needsNewBowler => _needsNewBowler;
  bool get canUndo => _history.isNotEmpty;

  bool get isChaseWon => _target != null && _runs >= _target!;
  bool get isInningsOver =>
      _wickets >= maxWickets ||
      _legalBalls >= setup.overs * 6 ||
      isChaseWon;
  bool get isInningsBreak => _innings == 1 && isInningsOver;
  bool get isMatchOver => _innings == 2 && isInningsOver;
  bool get canScore => !isInningsOver && !_needsNewBatter && !_needsNewBowler;

  String get chaseText {
    if (_target == null) return '';
    final runsNeeded = _target! - _runs;
    final ballsLeft = setup.overs * 6 - _legalBalls;
    return 'Need $runsNeeded off $ballsLeft balls';
  }

  String get resultText {
    if (_target == null) return '';
    if (_runs >= _target!) {
      final left = maxWickets - _wickets;
      return '$_battingTeam won by $left wicket${left == 1 ? '' : 's'}';
    }
    if (_runs == _target! - 1) return 'Match tied';
    final margin = _target! - 1 - _runs;
    return '$_bowlingTeam won by $margin run${margin == 1 ? '' : 's'}';
  }

  String? get winner {
    if (_target == null) return null;
    if (_runs >= _target!) return _battingTeam;
    if (_runs == _target! - 1) return null; // tie
    return _bowlingTeam;
  }

  MatchOutcome get outcome => MatchOutcome(
        result: resultText,
        winner: winner,
        firstBattingTeam: _bowlingTeam, // teams swapped at the innings break
        firstRuns: _firstRuns,
        firstBalls: _firstBalls,
        secondBattingTeam: _battingTeam,
        secondRuns: _runs,
        secondBalls: _legalBalls,
      );

  String batterFigures(String name) =>
      '${_batterRuns[name] ?? 0} (${_batterBalls[name] ?? 0})';

  List<Ball> get thisOver {
    if (_balls.isEmpty) return [];
    final current = _balls.last.over;
    return _balls.where((b) => b.over == current).toList();
  }

  // ---------- Actions ----------
  void recordBall({int runs = 0, Extra extra = Extra.none, bool isWicket = false}) {
    if (!canScore) return;
    _saveSnapshot();

    final ball = Ball(
      over: _legalBalls ~/ 6,
      runs: runs,
      extra: extra,
      isWicket: isWicket,
      batter: _striker,
      bowler: _bowler,
    );
    _balls.add(ball);
    _runs += ball.totalRuns;

    _batterRuns[_striker] = (_batterRuns[_striker] ?? 0) + runs;
    if (extra != Extra.wide) {
      _batterBalls[_striker] = (_batterBalls[_striker] ?? 0) + 1;
    }

    if (ball.isLegal) _legalBalls++;

    if (isWicket) {
      _wickets++;
      _outBatter = _striker;
      _dismissed.add(_striker);
      _needsNewBatter = !isInningsOver;
    }

    if (runs.isOdd) _swapStrike();

    if (ball.isLegal && _legalBalls % 6 == 0 && !isInningsOver) {
      _swapStrike();
      _needsNewBowler = true;
    }

    notifyListeners();
  }

  void setNewBatter(String name) {
    if (_striker == _outBatter) {
      _striker = name;
    } else {
      _nonStriker = name;
    }
    _needsNewBatter = false;
    notifyListeners();
  }

  void setNewBowler(String name) {
    _bowler = name;
    _needsNewBowler = false;
    notifyListeners();
  }

  void startSecondInnings({
    required String striker,
    required String nonStriker,
    required String bowler,
  }) {
    _firstRuns = _runs;
    _firstBalls = _legalBalls;
    _firstInningsSummary = '$_battingTeam $score ($overs ov)';
    _target = _runs + 1;

    final tempTeam = _battingTeam;
    _battingTeam = _bowlingTeam;
    _bowlingTeam = tempTeam;
    final tempSquad = _battingSquad;
    _battingSquad = _bowlingSquad;
    _bowlingSquad = tempSquad;
    _innings = 2;

    _runs = 0;
    _wickets = 0;
    _legalBalls = 0;
    _striker = striker;
    _nonStriker = nonStriker;
    _bowler = bowler;
    _outBatter = null;
    _dismissed = {};
    _needsNewBatter = false;
    _needsNewBowler = false;
    _balls = [];
    _batterRuns = {};
    _batterBalls = {};
    _history.clear();
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty) return;
    final s = _history.removeLast();
    _runs = s.runs;
    _wickets = s.wickets;
    _legalBalls = s.legalBalls;
    _striker = s.striker;
    _nonStriker = s.nonStriker;
    _bowler = s.bowler;
    _outBatter = s.outBatter;
    _dismissed = s.dismissed;
    _needsNewBatter = s.needsNewBatter;
    _needsNewBowler = s.needsNewBowler;
    _balls = s.balls;
    _batterRuns = s.batterRuns;
    _batterBalls = s.batterBalls;
    notifyListeners();
  }

  // ---------- Helpers ----------
  void _swapStrike() {
    final temp = _striker;
    _striker = _nonStriker;
    _nonStriker = temp;
  }

  void _saveSnapshot() {
    _history.add(_Snapshot(
      runs: _runs,
      wickets: _wickets,
      legalBalls: _legalBalls,
      striker: _striker,
      nonStriker: _nonStriker,
      bowler: _bowler,
      outBatter: _outBatter,
      dismissed: Set.of(_dismissed),
      needsNewBatter: _needsNewBatter,
      needsNewBowler: _needsNewBowler,
      balls: List.of(_balls),
      batterRuns: Map.of(_batterRuns),
      batterBalls: Map.of(_batterBalls),
    ));
  }
}

class _Snapshot {
  final int runs;
  final int wickets;
  final int legalBalls;
  final String striker;
  final String nonStriker;
  final String bowler;
  final String? outBatter;
  final Set<String> dismissed;
  final bool needsNewBatter;
  final bool needsNewBowler;
  final List<Ball> balls;
  final Map<String, int> batterRuns;
  final Map<String, int> batterBalls;

  const _Snapshot({
    required this.runs,
    required this.wickets,
    required this.legalBalls,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.outBatter,
    required this.dismissed,
    required this.needsNewBatter,
    required this.needsNewBowler,
    required this.balls,
    required this.batterRuns,
    required this.batterBalls,
  });
}