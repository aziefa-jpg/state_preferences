import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    final favorites = prefs.getStringList('favorites') ?? [];

    int currentCount = (prefs.getInt('visit_count') ?? 0) + 1;
    await prefs.setInt('visit_count', currentCount);

    _user = User(
      name: name,
      email: email,
      isLoggedIn: isLoggedIn,
      favorites: favorites,
    );
    _isDarkMode = isDarkMode;
    _visitCount = currentCount;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String item) async {
    final updatedList = List<String>.from(_user.favorites)..add(item);
    _user = _user.copyWith(favorites: updatedList);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedList);
  }

  Future<void> removeFavorite(String item) async {
    final updatedList = List<String>.from(_user.favorites)..remove(item);
    _user = _user.copyWith(favorites: updatedList);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedList);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }
}