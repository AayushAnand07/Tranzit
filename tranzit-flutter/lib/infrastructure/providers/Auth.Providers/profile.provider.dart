import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/user.services.dart';


class CreateProfileProvider with ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  Future<void> postProfile(String id, String name) async {
    try {
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




}
