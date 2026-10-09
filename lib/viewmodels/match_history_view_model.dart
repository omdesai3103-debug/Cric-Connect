import 'package:flutter/foundation.dart';
import '../models/match_outcome.dart';
import '../models/match_record.dart';

class MatchHistoryViewModel extends ChangeNotifier {
  final List<MatchRecord> _records = [];

  MatchHistoryViewModel() {
    _addSamples();
  }

  // Newest first
  List<MatchRecord> get records {
    final list = List.of(_records);
    list.sort((a, b) => b.playedOn.compareTo(a.playedOn));
    return list;
  }

  void add(MatchRecord record) {
    _records.add(record);
    notifyListeners();
  }

  // Matches the two sample results in the Auckland Friday League
  void _addSamples() {
    final now = DateTime.now();
    _records.addAll([
      MatchRecord(
        overs: 10,
        tournamentName: 'Auckland Friday League',
        playedOn: now.subtract(const Duration(days: 9)),
        outcome: const MatchOutcome(
          result: 'Mt Albert Strikers won by 7 runs',
          winner: 'Mt Albert Strikers',
          firstBattingTeam: 'Mt Albert Strikers',
          firstRuns: 82,
          firstBalls: 60,
          secondBattingTeam: 'Eden Eagles',
          secondRuns: 75,
          secondBalls: 60,
        ),
      ),
      MatchRecord(
        overs: 10,
        tournamentName: 'Auckland Friday League',
        playedOn: now.subtract(const Duration(days: 2)),
        outcome: const MatchOutcome(
          result: 'Ponsonby Panthers won by 4 wickets',
          winner: 'Ponsonby Panthers',
          firstBattingTeam: 'Eden Eagles',
          firstRuns: 64,
          firstBalls: 60,
          secondBattingTeam: 'Ponsonby Panthers',
          secondRuns: 65,
          secondBalls: 52,
        ),
      ),
    ]);
  }
}