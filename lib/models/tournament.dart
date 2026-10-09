class Fixture {
  final String id;
  final String teamA;
  final String teamB;
  String? result; // e.g. "Eagles won by 4 wickets"
  String? winner; // null means a tie
  int runsA = 0;
  int ballsA = 0;
  int runsB = 0;
  int ballsB = 0;

  Fixture({required this.id, required this.teamA, required this.teamB});

  bool get isPlayed => result != null;
}

class Tournament {
  final String id;
  final String name;
  final int overs;
  final int playersPerSide;
  final List<String> teams;
  final List<Fixture> fixtures;

  Tournament({
    required this.id,
    required this.name,
    required this.overs,
    required this.playersPerSide,
    required this.teams,
    required this.fixtures,
  });

  int get playedCount => fixtures.where((f) => f.isPlayed).length;
  bool get isComplete => fixtures.isNotEmpty && playedCount == fixtures.length;
}

class TeamStanding {
  final String team;
  int played = 0;
  int won = 0;
  int lost = 0;
  int tied = 0;
  int runsFor = 0;
  int ballsFaced = 0;
  int runsAgainst = 0;
  int ballsBowled = 0;

  TeamStanding(this.team);

  int get points => won * 2 + tied;

  // Net run rate = (runs scored per over) - (runs conceded per over)
  double get netRunRate {
    if (ballsFaced == 0 || ballsBowled == 0) return 0;
    return runsFor * 6 / ballsFaced - runsAgainst * 6 / ballsBowled;
  }
}