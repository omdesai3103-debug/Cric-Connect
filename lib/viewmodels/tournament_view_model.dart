import 'package:flutter/foundation.dart';
import '../models/match_outcome.dart';
import '../models/tournament.dart';

class TournamentViewModel extends ChangeNotifier {
  final List<Tournament> _tournaments = [];
  int _nextId = 1;

  TournamentViewModel() {
    _addSampleTournament();
  }

  // Newest first
  List<Tournament> get tournaments =>
      List.unmodifiable(_tournaments.reversed);

  Tournament byId(String id) => _tournaments.firstWhere((t) => t.id == id);

  // Round-robin: every team plays every other team once
  static List<Fixture> generateFixtures(List<String> teams) {
    final fixtures = <Fixture>[];
    for (var i = 0; i < teams.length; i++) {
      for (var j = i + 1; j < teams.length; j++) {
        fixtures.add(Fixture(
          id: 'f${fixtures.length + 1}',
          teamA: teams[i],
          teamB: teams[j],
        ));
      }
    }
    return fixtures;
  }

  Tournament createTournament({
    required String name,
    required int overs,
    required int playersPerSide,
    required List<String> teams,
  }) {
    final tournament = Tournament(
      id: 't${_nextId++}',
      name: name,
      overs: overs,
      playersPerSide: playersPerSide,
      teams: List.of(teams),
      fixtures: generateFixtures(teams),
    );
    _tournaments.add(tournament);
    notifyListeners();
    return tournament;
  }

  void recordResult(
    String tournamentId,
    String fixtureId, {
    required String result,
    required String? winner,
    required int runsA,
    required int ballsA,
    required int runsB,
    required int ballsB,
  }) {
    final fixture =
        byId(tournamentId).fixtures.firstWhere((f) => f.id == fixtureId);
    fixture.result = result;
    fixture.winner = winner;
    fixture.runsA = runsA;
    fixture.ballsA = ballsA;
    fixture.runsB = runsB;
    fixture.ballsB = ballsB;
    notifyListeners();
  }

  // Converts a finished match into the fixture's Team A / Team B numbers
  void recordOutcome(
      String tournamentId, String fixtureId, MatchOutcome outcome) {
    final fixture =
        byId(tournamentId).fixtures.firstWhere((f) => f.id == fixtureId);
    final aBattedFirst = outcome.firstBattingTeam == fixture.teamA;

    recordResult(
      tournamentId,
      fixtureId,
      result: outcome.result,
      winner: outcome.winner,
      runsA: aBattedFirst ? outcome.firstRuns : outcome.secondRuns,
      ballsA: aBattedFirst ? outcome.firstBalls : outcome.secondBalls,
      runsB: aBattedFirst ? outcome.secondRuns : outcome.firstRuns,
      ballsB: aBattedFirst ? outcome.secondBalls : outcome.firstBalls,
    );
  }

  List<TeamStanding> standings(Tournament tournament) {
    final table = {
      for (final team in tournament.teams) team: TeamStanding(team),
    };

    for (final f in tournament.fixtures.where((f) => f.isPlayed)) {
      final a = table[f.teamA]!;
      final b = table[f.teamB]!;
      a.played++;
      b.played++;
      a.runsFor += f.runsA;
      a.ballsFaced += f.ballsA;
      a.runsAgainst += f.runsB;
      a.ballsBowled += f.ballsB;
      b.runsFor += f.runsB;
      b.ballsFaced += f.ballsB;
      b.runsAgainst += f.runsA;
      b.ballsBowled += f.ballsA;

      if (f.winner == null) {
        a.tied++;
        b.tied++;
      } else if (f.winner == f.teamA) {
        a.won++;
        b.lost++;
      } else {
        b.won++;
        a.lost++;
      }
    }

    final list = table.values.toList();
    list.sort((x, y) {
      final byPoints = y.points.compareTo(x.points);
      return byPoints != 0 ? byPoints : y.netRunRate.compareTo(x.netRunRate);
    });
    return list;
  }

  // Demo data so the points table isn't empty on first launch
  void _addSampleTournament() {
    final t = createTournament(
      name: 'Auckland Friday League',
      overs: 10,
      playersPerSide: 8,
      teams: [
        'Mt Albert Strikers',
        'Eden Eagles',
        'Ponsonby Panthers',
        'Kingsland Kings',
      ],
    );
    recordResult(t.id, 'f1',
        result: 'Mt Albert Strikers won by 7 runs',
        winner: 'Mt Albert Strikers',
        runsA: 82, ballsA: 60, runsB: 75, ballsB: 60);
    recordResult(t.id, 'f4',
        result: 'Ponsonby Panthers won by 4 wickets',
        winner: 'Ponsonby Panthers',
        runsA: 64, ballsA: 60, runsB: 65, ballsB: 52);
  }
}