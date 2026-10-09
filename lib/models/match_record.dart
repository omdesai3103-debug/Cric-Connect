import 'match_outcome.dart';

class MatchRecord {
  final MatchOutcome outcome;
  final int overs;
  final DateTime playedOn;
  final String? tournamentName; // null = friendly match

  const MatchRecord({
    required this.outcome,
    required this.overs,
    required this.playedOn,
    this.tournamentName,
  });

  static String _oversText(int balls) => '${balls ~/ 6}.${balls % 6} ov';

  String get firstSummary => '${outcome.firstBattingTeam}  '
      '${outcome.firstRuns} (${_oversText(outcome.firstBalls)})';

  String get secondSummary => '${outcome.secondBattingTeam}  '
      '${outcome.secondRuns} (${_oversText(outcome.secondBalls)})';
}