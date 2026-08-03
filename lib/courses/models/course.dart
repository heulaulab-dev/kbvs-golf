import 'package:intl/intl.dart';

/// A golf course in the directory.
///
/// Mock data for now — real API not ready. Coordinates are approximate.
class Course {
  final String id;
  final String name;
  final String location;
  final String area;
  final int holes;
  final int par;
  final int greenFeeIdr;
  final double latitude;
  final double longitude;
  final bool isFeatured;

  const Course({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.holes,
    required this.par,
    required this.greenFeeIdr,
    required this.latitude,
    required this.longitude,
    this.isFeatured = false,
  });

  String get greenFeeLabel {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return 'Rp ${formatter.format(greenFeeIdr)}';
  }

  String get statsLabel => '$holes holes · Par $par';
}
