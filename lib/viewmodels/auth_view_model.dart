import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  String? _userName;
  String? _guestName;
  bool _isLoading = false;

  String? get userName => _userName;
  bool get isLoggedIn => _userName != null;
  bool get isLoading => _isLoading;
  bool get hasName => _userName != null || _guestName != null;

  // What every screen shows
  String get displayName => _userName ?? _guestName ?? 'Guest Player';

  // Mock login: no server yet, so any valid input succeeds
  Future<void> login(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    final raw = email.split('@').first;
    _userName = raw[0].toUpperCase() + raw.substring(1);
    _setLoading(false);
  }

  Future<void> signUp(String name, String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _userName = name;
    _setLoading(false);
  }

  void logout() {
    _userName = null;
    notifyListeners();
  }

  // Works for guests too: no account needed to set a name
  void updateName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    if (isLoggedIn) {
      _userName = clean;
    } else {
      _guestName = clean;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}