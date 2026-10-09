import 'package:flutter/foundation.dart';
import '../models/cricket_match.dart';
import '../repositories/match_repository.dart';

class HomeFeedViewModel extends ChangeNotifier {
  final MatchRepository _repository;
  HomeFeedViewModel(this._repository);

  List<CricketMatch> _matches = [];
  bool _isLoading = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get hasData => _matches.isNotEmpty;
  List<CricketMatch> get live => _byStatus(MatchStatus.live);
  List<CricketMatch> get upcoming => _byStatus(MatchStatus.upcoming);
  List<CricketMatch> get completed => _byStatus(MatchStatus.completed);

  List<CricketMatch> _byStatus(MatchStatus status) =>
      _matches.where((m) => m.status == status).toList();

  Future<void> loadFeed() async {
    _isLoading = true;
    _notify();
    _matches = await _repository.getFeed();
    _isLoading = false;
    _notify();
  }

  // Stops errors if the user switches tab while data is still loading
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}