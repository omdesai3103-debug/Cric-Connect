import '../models/cricket_match.dart';
import '../models/match_detail.dart';

class MatchRepository {
  // ---------- Home feed (fake data) ----------
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

  // ---------- Match detail (generated sample data) ----------
  MatchDetail getDetail(CricketMatch match) {
    final innings = <InningsCard>[];
    final first = match.scoreA == null
        ? null
        : _innings(match.teamA, match.teamB, match.scoreA!);
    final second = match.scoreB == null
        ? null
        : _innings(match.teamB, match.teamA, match.scoreB!);
    if (first != null) innings.add(first);
    if (second != null) innings.add(second);

    return MatchDetail(
      match: match,
      squadA: squad(match.teamA),
      squadB: squad(match.teamB),
      innings: innings,
      recentBalls: match.status == MatchStatus.live
          ? const ['1', '•', '4', '2', 'W', '1']
          : const [],
    );
  }

  static const _firstNames = [
    'Liam', 'Noah', 'Arjun', 'Jack', 'Rohan', 'Ethan', 'Kiran', 'Oliver',
    'Sam', 'Dev', 'Lucas', 'Ravi', 'Mason', 'Aarav', 'James', 'Hamish',
    'Tane', 'Nikhil', 'Leo', 'Finn', 'Ishaan', 'Ben', 'Kabir', 'Max',
    'Zane', 'Vihaan', 'Cooper', 'Manav', 'Tom', 'Rahul',
  ];

  static const _lastNames = [
    'Patel', 'Smith', 'Singh', 'Williams', 'Sharma', 'Brown', 'Taylor',
    'Ngata', 'Wilson', 'Mehta', 'Clarke', 'Reddy', 'Walker', 'Kumar',
    'Thompson', 'Joshi', 'Harris', 'Nair', 'Martin', 'Rao',
  ];

  // The same team name always gives the same 11 players
  List<String> squad(String team) {
    final seed = team.codeUnits.fold<int>(0, (a, b) => a + b);
    return [
      for (var i = 0; i < 11; i++)
        '${_firstNames[(seed + i * 7) % _firstNames.length]} '
            '${_lastNames[(seed * 3 + i * 3) % _lastNames.length]}',
    ];
  }

  // Reads "142/6 (20.0)" or "98 (14.1)" (no wickets shown = all out)
  ({int runs, int wickets, int balls})? _parse(String score) {
    final m = RegExp(r'^(\d+)(?:/(\d+))?\s*\((\d+)\.(\d)\)')
        .firstMatch(score.trim());
    if (m == null) return null;
    return (
      runs: int.parse(m.group(1)!),
      wickets: m.group(2) == null ? 10 : int.parse(m.group(2)!),
      balls: int.parse(m.group(3)!) * 6 + int.parse(m.group(4)!),
    );
  }

  InningsCard? _innings(String battingTeam, String bowlingTeam, String score) {
    final s = _parse(score);
    if (s == null) return null;

    final batters = squad(battingTeam);
    final fielders = squad(bowlingTeam);
    final bowlers = fielders.sublist(6); // players 7 to 11 bowl
    final extras = s.runs ~/ 15;
    final batted = (s.wickets + 2).clamp(2, 11);

    // Share the runs out, with the top order scoring most
    const weights = [24, 20, 16, 12, 9, 7, 5, 3, 2, 1, 1];
    final used = weights.take(batted).toList();
    final totalWeight = used.fold<int>(0, (a, b) => a + b);
    final batRuns = s.runs - extras;
    final runs = [for (final w in used) batRuns * w ~/ totalWeight];
    runs[0] += batRuns - runs.fold<int>(0, (a, b) => a + b);

    // Batting card, crediting each dismissal to a bowler
    final bowlerWickets = List.filled(bowlers.length, 0);
    final batting = <BattingEntry>[];
    for (var i = 0; i < batted; i++) {
      var dismissal = 'not out';
      if (i < s.wickets) {
        final b = i % bowlers.length;
        final bowler = bowlers[b];
        final fielder = fielders[(i + 2) % fielders.length];
        switch (i % 5) {
          case 0:
            dismissal = 'c $fielder b $bowler';
            bowlerWickets[b]++;
          case 1:
            dismissal = 'b $bowler';
            bowlerWickets[b]++;
          case 2:
            dismissal = 'lbw b $bowler';
            bowlerWickets[b]++;
          case 3:
            dismissal = 'run out ($fielder)';
          default:
            dismissal = 'c & b $bowler';
            bowlerWickets[b]++;
        }
      }
      final r = runs[i];
      batting.add(BattingEntry(
        name: batters[i],
        dismissal: dismissal,
        runs: r,
        balls: r == 0 ? 2 : (r * 0.85).round() + 2,
        fours: r ~/ 12,
        sixes: r ~/ 25,
      ));
    }

    // Bowling card: share the overs and runs between 5 bowlers
    final fullOvers = s.balls ~/ 6;
    final ballsEach = [
      for (var i = 0; i < bowlers.length; i++)
        (fullOvers ~/ bowlers.length +
                (i < fullOvers % bowlers.length ? 1 : 0)) *
            6,
    ];
    ballsEach[fullOvers % bowlers.length] += s.balls % 6;

    final totalBalls = ballsEach.fold<int>(0, (a, b) => a + b);
    final conceded = s.runs - extras ~/ 2;
    final runsEach = [
      for (final b in ballsEach)
        totalBalls == 0 ? 0 : conceded * b ~/ totalBalls,
    ];
    runsEach[0] += conceded - runsEach.fold<int>(0, (a, b) => a + b);

    final bowling = <BowlingEntry>[
      for (var i = 0; i < bowlers.length; i++)
        if (ballsEach[i] > 0)
          BowlingEntry(
            name: bowlers[i],
            balls: ballsEach[i],
            runs: runsEach[i],
            wickets: bowlerWickets[i],
          ),
    ];

    return InningsCard(
      team: battingTeam,
      score: score,
      extras: extras,
      batting: batting,
      bowling: bowling,
    );
  }
}