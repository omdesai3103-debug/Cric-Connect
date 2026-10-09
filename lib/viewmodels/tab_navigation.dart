import 'package:flutter/foundation.dart';

// Remembers which bottom tab is open, so any screen (like the drawer) can switch it
class TabNavigation extends ChangeNotifier {
  static const home = 0;
  static const score = 1;
  static const tournaments = 2;
  static const career = 3;

  int _index = home;
  int get index => _index;

  void go(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}