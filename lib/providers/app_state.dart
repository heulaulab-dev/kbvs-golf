import 'package:flutter/foundation.dart';

import '../caddy/calculator.dart';

class AppState extends ChangeNotifier {
  // Core app state — user prefs, auth, loading status, etc.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Application settings from persistent storage
  String? _currentCourse;
  String? get currentCourse => _currentCourse;

  void setCurrentCourse(String course) {
    if (_currentCourse != course) {
      _currentCourse = course;
      notifyListeners();
    }
  }

  // AI feature flags (from PRD — caddy tips on/off)
  bool _caddyTipsEnabled = true;
  bool get caddyTipsEnabled => _caddyTipsEnabled;

  void toggleCaddyTips() {
    _caddyTipsEnabled = !_caddyTipsEnabled;
    notifyListeners();
  }

  // Caddy tips tracking
  int? _currentYardage;
  int? get currentYardage => _currentYardage;

  double? _currentFee;
  double? get currentFee => _currentFee;

  // Set yardage and calculate fee
  void setYardage(int yardage) {
    if (_currentYardage == yardage) return;

    _currentYardage = yardage;

    if (yardage <= 0) {
      // No distance = no charge
      _currentFee = 0.0;
    } else if (!caddyTipsEnabled) {
      _currentFee = null;
    } else {
      // Calculate fee using calculator with min/max caps
      final calc = CaddyFeeCalculator();
      _currentFee = calc.calculateFee(yardage);
    }

    notifyListeners();
  }

  // Reset yardage to null (clears fee too)
  void resetYardage() {
    if (_currentYardage == null) return;
    _currentYardage = null;
    _currentFee = null;
    notifyListeners();
  }
}
