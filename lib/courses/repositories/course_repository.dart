import '../models/course.dart';

/// Abstraction for course data source. Mock implementation for now,
/// HTTP repository later when the backend API is ready.
abstract class CourseRepository {
  Future<List<Course>> getCourses();
}
