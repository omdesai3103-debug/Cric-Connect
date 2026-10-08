import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  String? _userName;
  bool _isLoading = false;

  String? get userName => _userName;
  bool get isLoggedIn => _userName != null;
  bool get isLoading => _isLoading;

  // Mock login: no server yet, so any valid input succeeds
  Future<void> login(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    _userName = email.split('@').first;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}