import 'package:intl/intl.dart';

import 'skill_level.dart';
import 'tournament_format.dart';
import 'tournament_status.dart';

class Tournament {
  final String id;
  final String name;
  final String courseName;
  final String courseLocation;
  final TournamentFormat format;
  final SkillLevel minSkill;
  final int maxFeeIdr;
  final DateTime startDate;
  final DateTime endDate;
  final TournamentStatus status;
  final int registeredCount;
  final int maxCapacity;
  final bool isFeatured;

  const Tournament({
    required this.id,
    required this.name,
    required this.courseName,
    required this.courseLocation,
    required this.format,
    required this.minSkill,
    required this.maxFeeIdr,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.registeredCount,
    required this.maxCapacity,
    required this.isFeatured,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>;
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      courseName: course['name'] as String,
      courseLocation: course['location'] as String,
      format: TournamentFormat.fromApi(json['format'] as String),
      minSkill: SkillLevel.fromApi(json['min_skill'] as String),
      maxFeeIdr: json['max_fee_idr'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: TournamentStatus.fromApi(json['status'] as String),
      registeredCount: json['registered_count'] as int,
      maxCapacity: json['max_capacity'] as int,
      isFeatured: (json['is_featured'] as bool?) ?? false,
    );
  }

  bool get isFull => registeredCount >= maxCapacity;

  bool get isVisibleToPublic => status == TournamentStatus.approved;

  String get feeLabel {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return 'Rp ${formatter.format(maxFeeIdr)}';
  }

  String get capacityLabel => '$registeredCount / $maxCapacity';
}
