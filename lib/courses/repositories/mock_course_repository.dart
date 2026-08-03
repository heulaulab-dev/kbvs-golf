import 'dart:async';

import '../models/course.dart';
import 'course_repository.dart';

/// Mock course data — real Jakarta golf courses with approximate
/// coordinates. Swap for HTTP repository when the backend is ready.
class MockCourseRepository implements CourseRepository {
  static const List<Course> _mockCourses = [
    Course(
      id: 'pondok-indah',
      name: 'Pondok Indah Golf Club',
      location: 'Jl. Metro Pondok Indah, Jakarta Selatan',
      area: 'South Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 750000,
      latitude: -6.2735,
      longitude: 106.7864,
      isFeatured: true,
    ),
    Course(
      id: 'senayan',
      name: 'Jakarta Golf Club (Senayan)',
      location: 'Gelora Bung Karno, Jakarta Pusat',
      area: 'Central Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 650000,
      latitude: -6.2156,
      longitude: 106.8026,
    ),
    Course(
      id: 'emeralda',
      name: 'Emeralda Golf Club',
      location: 'Jl. Raya Cimanggis, Depok',
      area: 'South Jakarta',
      holes: 27,
      par: 108,
      greenFeeIdr: 900000,
      latitude: -6.3775,
      longitude: 106.8744,
    ),
    Course(
      id: 'damai-indah',
      name: 'Damai Indah Golf',
      location: 'Jl. Raya Pantai Indah Kapuk, Jakarta Utara',
      area: 'North Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 700000,
      latitude: -6.1136,
      longitude: 106.7405,
    ),
    Course(
      id: 'cengkareng',
      name: 'Cengkareng Golf Club',
      location: 'Jl. Soekarno-Hatta, Jakarta Barat',
      area: 'West Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 500000,
      latitude: -6.1473,
      longitude: 106.7066,
    ),
    Course(
      id: 'jagorawi',
      name: 'Jagorawi Golf & Country Club',
      location: 'Jl. Raya Jakarta-Bogor, Cibubur',
      area: 'East Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 800000,
      latitude: -6.4189,
      longitude: 106.9158,
    ),
    Course(
      id: 'rancamaya',
      name: 'Rancamaya Golf & CC',
      location: 'Jl. Rancamaya Utama, Bogor',
      area: 'South Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 850000,
      latitude: -6.5685,
      longitude: 106.7832,
    ),
    Course(
      id: 'riverside',
      name: 'Riverside Golf Club',
      location: 'Jl. Raya Bogor, Cibubur',
      area: 'East Jakarta',
      holes: 18,
      par: 72,
      greenFeeIdr: 600000,
      latitude: -6.3942,
      longitude: 106.8873,
    ),
  ];

  @override
  Future<List<Course>> getCourses() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCourses;
  }
}
