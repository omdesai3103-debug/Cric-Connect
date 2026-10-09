class MatchSetup {
  final String battingTeam;
  final String bowlingTeam;
  final List<String> battingSquad;
  final List<String> bowlingSquad;
  final int overs;
  final int playersPerSide;
  final String striker;
  final String nonStriker;
  final String bowler;

  const MatchSetup({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.battingSquad,
    required this.bowlingSquad,
    required this.overs,
    required this.playersPerSide,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
  });
}