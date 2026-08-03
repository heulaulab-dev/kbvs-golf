import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tournament/models/skill_level.dart';

/// Manages onboarding state progression and user data collection.
///
/// Tracks current step, saves collected data (name, skill level, location, preferences),
/// and persists state across app restarts via SharedPreferences.
/// Follows the ChangeNotifier pattern used throughout the app (similar to AuthProvider).
class OnboardingProvider with ChangeNotifier {
  // Current step index: 0=welcome, 1=profile, 2=sick, 3=preferences, 4=complete
  int _currentStep = 0;

  // Whether onboarding has been completed
  bool _completed = false;

  // Collected user data
  String? _userName;
  SkillLevel? _skillLevel;
  String? _location;
  bool _showNearby = true;
  bool _emailNotifications = true;

  // Step getters
  int get currentStep => _currentStep;
  bool get completed => _completed;

  // Data getters
  String? get userName => _userName;
  SkillLevel? get skillLevel => _skillLevel;
  String? get location => _location;
  bool get showNearby => _showNearby;
  bool get emailNotifications => _emailNotifications;

  OnboardingProvider() {
    _loadFromPrefs();
  }

  /// Load saved state from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStep = prefs.getInt('onboarding_step') ?? 0;
      _userName = prefs.getString('onboarding_name');
      _skillLevel = SkillLevel.values.byName(prefs.getString('onboarding_skill') ?? 'beginner');
      _location = prefs.getString('onboarding_location');
      _showNearby = prefs.getBool('on_show_nearby') ?? true;
      _emailNotifications = prefs.getBool('on_email_notifs') ?? true;
      _completed = prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      if (kDebugMode) print('Error loading onboarding state: $e');
    }
  }

  /// Save current state to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('onboarding_step', _currentStep);
      if (_userName != null) prefs.setString('onboarding_name', _userName!);
      if (_skillLevel != null) prefs.setString('onboarding_skill', _skillLevel!.name);
      if (_location != null) prefs.setString('onboarding_location', _location!);
      prefs.setBool('on_show_nearby', _showNearby);
      prefs.setBool('on_email_notifs', _emailNotifications);
      prefs.setBool('onboarding_completed', _completed);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error saving onboarding state: $e');
    }
  }

  /// Advance to the next step
  void nextStep() {
    if (!_completed && _currentStep < 3) {
      _currentStep++;
      _saveToPrefs();
    }
  }

  /// Go back to the previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _saveToPrefs();
    }
  }

  /// Complete onboarding process
  void completeOnboarding() {
    if (!_completed) {
      _completed = true;
      _saveToPrefs();
    }
  }

  /// Set profile information (name and skill level) at profile step
  void setProfileInfo({required String name, required SkillLevel level}) {
    _userName = name.trim();
    _skillLevel = level;
    nextStep();
  }

  /// Set skill level only (skill screen selection).
  void setSkillLevel(SkillLevel level) {
    _skillLevel = level;
    _saveToPrefs();
  }

  /// Set location at preferences step (does not complete onboarding)
  void setLocationAndPreferences({
    required String location,
    required bool showNearby,
    required bool emailNotifications,
  }) {
    _location = location.isNotEmpty ? location : null;
    _showNearby = showNearby;
    _emailNotifications = emailNotifications;
    _saveToPrefs();
  }

  /// Update preference toggles without touching location or completing
  /// onboarding. Used by the Profile screen settings section.
  void updatePreferences({
    required bool showNearby,
    required bool emailNotifications,
  }) {
    _showNearby = showNearby;
    _emailNotifications = emailNotifications;
    _saveToPrefs();
  }

  /// Complete onboarding process
  void finishOnboarding() {
    if (!_completed) {
      _completed = true;
      _saveToPrefs();
    }
  }

  /// Reset onboarding state (for testing/recovery)
  void reset() {
    _currentStep = 0;
    _userName = null;
    _skillLevel = null;
    _location = null;
    _showNearby = true;
    _emailNotifications = true;
    _completed = false;
    _saveToPrefs();
  }

  /// Determine if a screen should show based on current step
  bool isVisible(int step) {
    return _currentStep == step || !_completed;
  }

  /// Get the total number of steps (excluding completion)
  int get totalSteps => 4; // welcome, profile, skill, preferences
}
