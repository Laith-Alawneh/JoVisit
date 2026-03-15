import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider with ChangeNotifier {
  final Set<int> _favoriteIds = {};
  static const String _prefsKey = 'favorite_landmarks';

  Set<int> get favorites => _favoriteIds;

  bool isFavorite(int landmarkId) {
    return _favoriteIds.contains(landmarkId);
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_prefsKey);
      
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favoriteIds.clear();
        _favoriteIds.addAll(decoded.cast<int>());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<bool> toggleFavorite(int landmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_favoriteIds.contains(landmarkId)) {
        _favoriteIds.remove(landmarkId);
      } else {
        _favoriteIds.add(landmarkId);
      }
      
      final encoded = json.encode(_favoriteIds.toList());
      await prefs.setString(_prefsKey, encoded);
      
      notifyListeners();
      return _favoriteIds.contains(landmarkId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }
}
