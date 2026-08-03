import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

/// State for the courses directory. Loads from repository, filters
/// by area client-side.
class CoursesProvider extends ChangeNotifier {
  CoursesProvider({required CourseRepository repository})
      : _repository = repository;

  final CourseRepository _repository;

  List<Course> _courses = [];
  String _areaFilter = 'All';
  bool _loading = true;
  String _errorText = '';

  List<Course> get courses => _courses;
  String get areaFilter => _areaFilter;
  bool get loading => _loading;
  String get errorText => _errorText;

  List<String> get areas {
    final unique = _courses.map((c) => c.area).toSet().toList()..sort();
    return ['All', ...unique];
  }

  List<Course> get filteredCourses => _areaFilter == 'All'
      ? _courses
      : _courses.where((c) => c.area == _areaFilter).toList();

  Future<void> load() async {
    _loading = true;
    _errorText = '';
    notifyListeners();

    try {
      _courses = await _repository.getCourses();
    } catch (e) {
      _errorText = 'Failed to load courses. Pull to retry.';
      if (kDebugMode) debugPrint('CoursesProvider error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setAreaFilter(String area) {
    if (_areaFilter == area) return;
    _areaFilter = area;
    notifyListeners();
  }
}
