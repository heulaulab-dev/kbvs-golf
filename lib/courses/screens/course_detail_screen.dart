import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../tournament/providers/changes_notifier_tournament_provider.dart';
import '../models/course.dart';

/// Detail screen for a single golf course.
/// Shows stats, mock map placeholder, and tournaments at this course.
class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final tournamentProvider = context.watch<ChangesNotifierTournamentProvider>();
    final tournamentsHere = tournamentProvider.tournaments
        .where((t) => t.courseName == course.name && t.isVisibleToPublic)
        .toList();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          course.name,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: GolfieColors.skyGradient.colors.first.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.area,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: GolfieColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: GolfieColors.stone),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    course.location,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: GolfieColors.graphite,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats row — 3 stat boxes
            Row(
              children: [
                _StatBox(label: 'Holes', value: '${course.holes}'),
                const SizedBox(width: 12),
                _StatBox(label: 'Par', value: '${course.par}'),
                const SizedBox(width: 12),
                _StatBox(label: 'Green Fee', value: course.greenFeeLabel),
              ],
            ),
            const SizedBox(height: 24),

            // Map placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 32, color: GolfieColors.ink),
                  const SizedBox(height: 8),
                  Text(
                    'Map coming soon',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: GolfieColors.graphite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.latitude}, ${course.longitude}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: GolfieColors.stone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tournaments at this course
            Text(
              'Tournaments here',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            if (tournamentsHere.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GolfieColors.white,
                  borderRadius: BorderRadius.circular(GolfieRadii.xl),
                  border: Border.all(color: GolfieColors.ash),
                ),
                child: Text(
                  'No tournaments at this course yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: GolfieColors.stone,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...tournamentsHere.map((tournament) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GolfieColors.white,
                      borderRadius: BorderRadius.circular(GolfieRadii.xl),
                      border: Border.all(color: GolfieColors.ash),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: GolfieColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: GolfieColors.stone),
                            const SizedBox(width: 4),
                            Text(
                              '${tournament.startDate.day}/${tournament.startDate.month}/${tournament.startDate.year}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: GolfieColors.graphite,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              tournament.capacityLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: GolfieColors.graphite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: GolfieColors.white,
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          border: Border.all(color: GolfieColors.ash),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: GolfieColors.stone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
