enum Extra { none, wide, noBall }

class Ball {
  final int over; // which over it was bowled in (0 = first over)
  final int runs; // runs off the bat
  final Extra extra;
  final bool isWicket;
  final String batter;
  final String bowler;

  const Ball({
    required this.over,
    this.runs = 0,
    this.extra = Extra.none,
    this.isWicket = false,
    required this.batter,
    required this.bowler,
  });

  // Wides and no-balls don't count as one of the 6 balls
  bool get isLegal => extra == Extra.none;

  // Wides and no-balls add 1 extra run
  int get totalRuns => runs + (isLegal ? 0 : 1);

  String get label {
    if (isWicket) return 'W';
    if (extra == Extra.wide) return 'Wd';
    if (extra == Extra.noBall) return 'Nb';
    return runs == 0 ? '•' : '$runs';
  }
}