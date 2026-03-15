import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for managing gamification state (completed quizzes and unlocked badges)
/// 
/// Uses SharedPreferences for persistent storage
/// Tracks user progress across landmark-specific quizzes
class GamificationProvider with ChangeNotifier {
  final Set<String> _completedQuizzes = {}; // Set of landmark IDs (as strings)
  final Set<String> _unlockedBadges = {}; // Set of badge IDs
  static const String _prefsKeyCompleted = 'completed_quizzes';
  static const String _prefsKeyBadges = 'unlocked_badges';

  /// Get set of completed quiz landmark IDs
  Set<String> get completedQuizzes => _completedQuizzes;

  /// Get set of unlocked badge IDs
  Set<String> get unlockedBadges => _unlockedBadges;

  /// Check if a landmark's quiz has been completed
  /// 
  /// [landmarkId] - The ID of the landmark (as string)
  /// Returns true if the quiz has been completed
  bool isQuizCompleted(String landmarkId) {
    return _completedQuizzes.contains(landmarkId);
  }

  /// Check if a badge has been unlocked
  /// 
  /// [badgeId] - The ID of the badge
  /// Returns true if the badge is unlocked
  bool isBadgeUnlocked(String badgeId) {
    return _unlockedBadges.contains(badgeId);
  }

  /// Load gamification progress from local storage
  /// 
  /// Called on app initialization to restore saved progress
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load completed quizzes
      final completedJson = prefs.getString(_prefsKeyCompleted);
      if (completedJson != null) {
        final List<dynamic> decoded = json.decode(completedJson);
        _completedQuizzes.clear();
        _completedQuizzes.addAll(decoded.cast<String>());
      }
      
      // Load unlocked badges
      final badgesJson = prefs.getString(_prefsKeyBadges);
      if (badgesJson != null) {
        final List<dynamic> decoded = json.decode(badgesJson);
        _unlockedBadges.clear();
        _unlockedBadges.addAll(decoded.cast<String>());
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading gamification progress: $e');
    }
  }

  /// Unlock a badge for a landmark
  /// 
  /// [landmarkId] - The ID of the landmark (as string) to unlock badge for
  /// Marks the quiz as completed and unlocks the corresponding badge
  /// Persists the changes to SharedPreferences
  Future<void> unlockBadge(String landmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mark quiz as completed
      _completedQuizzes.add(landmarkId);
      
      // Unlock badge (using landmarkId as badgeId)
      _unlockedBadges.add(landmarkId);
      
      // Save to preferences
      final completedEncoded = json.encode(_completedQuizzes.toList());
      final badgesEncoded = json.encode(_unlockedBadges.toList());
      
      await prefs.setString(_prefsKeyCompleted, completedEncoded);
      await prefs.setString(_prefsKeyBadges, badgesEncoded);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error unlocking badge: $e');
    }
  }

  /// Mark a quiz as completed without unlocking badge
  /// 
  /// [landmarkId] - The ID of the landmark (as string)
  Future<void> markQuizCompleted(String landmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _completedQuizzes.add(landmarkId);
      
      final encoded = json.encode(_completedQuizzes.toList());
      await prefs.setString(_prefsKeyCompleted, encoded);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking quiz as completed: $e');
    }
  }

  /// Clear all gamification progress
  /// 
  /// Removes all completed quizzes and unlocked badges from storage and memory
  Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyCompleted);
      await prefs.remove(_prefsKeyBadges);
      _completedQuizzes.clear();
      _unlockedBadges.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing gamification progress: $e');
    }
  }
}
