import 'cricket_match.dart';

class BattingEntry {
  final String name;
  final String dismissal; // e.g. "b Liam Patel" or "not out"
  final int runs;
  final int balls;
  final int fours;
  final int sixes;

  const BattingEntry({
    required this.name,
    required this.dismissal,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
  });

  bool get isNotOut => dismissal == 'not out';
  String get strikeRate =>
      balls == 0 ? '0.0' : (runs * 100 / balls).toStringAsFixed(1);
}

class BowlingEntry {
  final String name;
  final int balls;
  final int runs;
  final int wickets;

  const BowlingEntry({
    required this.name,
    required this.balls,
    required this.runs,
    required this.wickets,
  });

  String get overs => '${balls ~/ 6}.${balls % 6}';
  String get economy =>
      balls == 0 ? '0.00' : (runs * 6 / balls).toStringAsFixed(2);
}

class InningsCard {
  final String team;
  final String score;
  final int extras;
  final List<BattingEntry> batting;
  final List<BowlingEntry> bowling;

  const InningsCard({
    required this.team,
    required this.score,
    required this.extras,
    required this.batting,
    required this.bowling,
  });
}

class MatchDetail {
  final CricketMatch match;
  final List<String> squadA;
  final List<String> squadB;
  final List<InningsCard> innings;
  final List<String> recentBalls;

  const MatchDetail({
    required this.match,
    required this.squadA,
    required this.squadB,
    required this.innings,
    required this.recentBalls,
  });
}