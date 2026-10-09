enum MatchStatus { live, upcoming, completed }

class CricketMatch {
  final String id;
  final String teamA;
  final String teamB;
  final String? scoreA;
  final String? scoreB;
  final String venue;
  final DateTime startTime;
  final MatchStatus status;
  final String? summary; // e.g. "Eagles need 24 runs off 30 balls"

  const CricketMatch({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    required this.venue,
    required this.startTime,
    required this.status,
    this.summary,
  });
}