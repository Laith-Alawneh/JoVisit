import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for managing favorite landmarks
/// 
/// Uses SharedPreferences for persistent storage
/// Demonstrates professional state management and local data persistence
class FavoritesProvider with ChangeNotifier {
  final Set<int> _favoriteIds = {};
  static const String _prefsKey = 'favorite_landmarks';

  /// Get list of favorite landmark IDs
  Set<int> get favorites => _favoriteIds;

  /// Check if a landmark is favorited
  /// 
  /// [landmarkId] - The ID of the landmark to check
  /// Returns true if the landmark is in favorites
  bool isFavorite(int landmarkId) {
    return _favoriteIds.contains(landmarkId);
  }

  /// Load favorites from local storage
  /// 
  /// Called on app initialization to restore saved favorites
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

  /// Toggle favorite status of a landmark
  /// 
  /// [landmarkId] - The ID of the landmark to toggle
  /// Returns true if added to favorites, false if removed
  Future<bool> toggleFavorite(int landmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_favoriteIds.contains(landmarkId)) {
        _favoriteIds.remove(landmarkId);
      } else {
        _favoriteIds.add(landmarkId);
      }
      
      // Save to preferences
      final encoded = json.encode(_favoriteIds.toList());
      await prefs.setString(_prefsKey, encoded);
      
      notifyListeners();
      return _favoriteIds.contains(landmarkId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Clear all favorites
  /// 
  /// Removes all favorites from storage and memory
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      _favoriteIds.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }
}
