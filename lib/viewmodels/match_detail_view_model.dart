import '../models/cricket_match.dart';
import '../models/match_detail.dart';
import '../repositories/match_repository.dart';

// The data doesn't change while you're viewing it,
// so this ViewModel doesn't need ChangeNotifier
class MatchDetailViewModel {
  final MatchDetail detail;

  MatchDetailViewModel(CricketMatch match, MatchRepository repository)
      : detail = repository.getDetail(match);

  CricketMatch get match => detail.match;
  bool get isLive => match.status == MatchStatus.live;
  bool get isUpcoming => match.status == MatchStatus.upcoming;
  bool get isCompleted => match.status == MatchStatus.completed;

  String get overviewLabel => isLive
      ? 'Live'
      : isUpcoming
          ? 'Info'
          : 'Summary';

  String get statusLine => isUpcoming
      ? 'Starts ${_formatStart(match.startTime)}'
      : (match.summary ?? '');

  InningsCard? get currentInnings =>
      detail.innings.isEmpty ? null : detail.innings.last;

  List<BattingEntry> get battingNow =>
      currentInnings?.batting.where((b) => b.isNotOut).toList() ?? [];

  BowlingEntry? get currentBowler {
    final innings = currentInnings;
    if (innings == null || innings.bowling.isEmpty) return null;
    return innings.bowling.last;
  }

  BattingEntry? get topScorer {
    final all = [for (final i in detail.innings) ...i.batting];
    if (all.isEmpty) return null;
    return all.reduce((a, b) => b.runs > a.runs ? b : a);
  }

  BowlingEntry? get bestBowler {
    final all = [for (final i in detail.innings) ...i.bowling];
    if (all.isEmpty) return null;
    return all.reduce((a, b) =>
        b.wickets > a.wickets || (b.wickets == a.wickets && b.runs < a.runs)
            ? b
            : a);
  }

  String _formatStart(DateTime time) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'am' : 'pm';
    return '${days[time.weekday - 1]} ${time.day}/${time.month}, '
        '$hour:$minute $period';
  }
}