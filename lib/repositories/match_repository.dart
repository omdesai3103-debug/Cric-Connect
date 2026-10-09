import '../models/cricket_match.dart';

class MatchRepository {
  // Fake data for the prototype. Later this can read from SQLite.
  Future<List<CricketMatch>> getFeed() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();

    return [
      CricketMatch(
        id: 'm1',
        teamA: 'Mt Albert Strikers',
        teamB: 'Eden Eagles',
        scoreA: '142/6 (20.0)',
        scoreB: '119/4 (15.0)',
        venue: 'Fowlds Park',
        startTime: now.subtract(const Duration(hours: 2)),
        status: MatchStatus.live,
        summary: 'Eagles need 24 runs off 30 balls',
      ),
      CricketMatch(
        id: 'm2',
        teamA: 'Sandringham Smashers',
        teamB: 'Kingsland Kings',
        scoreA: '67/2 (8.3)',
        venue: 'Gribblehirst Park',
        startTime: now.subtract(const Duration(minutes: 40)),
        status: MatchStatus.live,
        summary: 'Smashers batting first',
      ),
      CricketMatch(
        id: 'm3',
        teamA: 'Ponsonby Panthers',
        teamB: 'Grey Lynn Giants',
        venue: "Cox's Bay Reserve",
        startTime: now.add(const Duration(days: 1, hours: 3)),
        status: MatchStatus.upcoming,
      ),
      CricketMatch(
        id: 'm4',
        teamA: 'AUT Friday XI',
        teamB: 'Mt Roskill Rangers',
        venue: 'Keith Hay Park',
        startTime: now.add(const Duration(days: 2)),
        status: MatchStatus.upcoming,
      ),
      CricketMatch(
        id: 'm5',
        teamA: 'Eden Eagles',
        teamB: 'Ponsonby Panthers',
        scoreA: '156/8 (20.0)',
        scoreB: '157/5 (19.2)',
        venue: 'Cornwall Park',
        startTime: now.subtract(const Duration(days: 2)),
        status: MatchStatus.completed,
        summary: 'Panthers won by 5 wickets',
      ),
      CricketMatch(
        id: 'm6',
        teamA: 'Kingsland Kings',
        teamB: 'Mt Albert Strikers',
        scoreA: '98 (14.1)',
        scoreB: '99/3 (11.4)',
        venue: 'Fowlds Park',
        startTime: now.subtract(const Duration(days: 4)),
        status: MatchStatus.completed,
        summary: 'Strikers won by 7 wickets',
      ),
    ];
  }
}