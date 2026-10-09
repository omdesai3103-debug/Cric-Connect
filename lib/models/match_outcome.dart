class MatchOutcome {
  final String result; // e.g. "Eden Eagles won by 3 wickets"
  final String? winner; // null means a tie
  final String firstBattingTeam;
  final int firstRuns;
  final int firstBalls;
  final String secondBattingTeam;
  final int secondRuns;
  final int secondBalls;

  const MatchOutcome({
    required this.result,
    required this.winner,
    required this.firstBattingTeam,
    required this.firstRuns,
    required this.firstBalls,
    required this.secondBattingTeam,
    required this.secondRuns,
    required this.secondBalls,
  });
}