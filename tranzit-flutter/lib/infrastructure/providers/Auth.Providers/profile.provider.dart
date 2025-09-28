import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/user.services.dart';

class CreateProfileProvider with ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  String _userName = '';
  String get userName => _userName;

  // Add this method to clear errors
  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> postProfile(String id, String name) async {
    try {
      _error = '';
      _isLoading = true;
      notifyListeners();

      final user = await _userService.createUser(id, name);

      _isLoading = false;
      notifyListeners();
      print('User created: $user');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error: $_error');
    }
  }

  Future<void> getUserName(String id) async {
    try {
      _error = ''; // Clear previous errors
      _isLoading = true;
      notifyListeners();

      _userName = await _userService.getUserByUid(id);

      _isLoading = false;
      notifyListeners();
      print('User fetched: $_userName');
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      print('Error: $_error');
    }
  }
}