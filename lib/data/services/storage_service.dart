import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence service using SharedPreferences.
///
/// Handles serialization/deserialization of child profiles,
/// letter progress, settings, and session history.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  // Keys
  static const _profilesKey = 'child_profiles';
  static const _activeProfileKey = 'active_profile_id';
  static const _progressKeyPrefix = 'letter_progress_';
  static const _settingsKey = 'app_settings';
  static const _totalStarsKeyPrefix = 'total_stars_';

  /// Create from SharedPreferences instance.
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Profiles ---

  /// Get all saved child profiles as JSON list.
  List<Map<String, dynamic>> getProfiles() {
    final raw = _prefs.getString(_profilesKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error reading profiles: $e');
      return [];
    }
  }

  /// Save all child profiles.
  Future<bool> saveProfiles(List<Map<String, dynamic>> profiles) {
    return _prefs.setString(_profilesKey, jsonEncode(profiles));
  }

  /// Get the active profile ID.
  String? getActiveProfileId() {
    return _prefs.getString(_activeProfileKey);
  }

  /// Set the active profile ID.
  Future<bool> setActiveProfileId(String id) {
    return _prefs.setString(_activeProfileKey, id);
  }

  // --- Progress ---

  /// Get letter progress data for a specific profile.
  Map<String, Map<String, dynamic>> getLetterProgress(String profileId) {
    final raw = _prefs.getString('$_progressKeyPrefix$profileId');
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error reading progress: $e');
      return {};
    }
  }

  /// Save letter progress for a specific profile.
  Future<bool> saveLetterProgress(
    String profileId,
    Map<String, Map<String, dynamic>> progress,
  ) {
    return _prefs.setString(
      '$_progressKeyPrefix$profileId',
      jsonEncode(progress),
    );
  }

  // --- Stars ---

  /// Get total stars for a profile.
  int getTotalStars(String profileId) {
    return _prefs.getInt('$_totalStarsKeyPrefix$profileId') ?? 0;
  }

  /// Set total stars for a profile.
  Future<bool> setTotalStars(String profileId, int stars) {
    return _prefs.setInt('$_totalStarsKeyPrefix$profileId', stars);
  }

  // --- Settings ---

  /// Get app settings as a map.
  Map<String, dynamic> getSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading settings: $e');
      return {};
    }
  }

  /// Save app settings.
  Future<bool> saveSettings(Map<String, dynamic> settings) {
    return _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  /// Clear all data (for testing/reset).
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}
