import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'course_detail_screen.dart';

/// Course directory — area filter chips + course list.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<CoursesProvider>();
      if (provider.courses.isEmpty && !provider.loading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Courses',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(),
        color: GolfieColors.ink,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Area filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: provider.areas.map((area) {
                    final selected = provider.areaFilter == area;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(area),
                        selected: selected,
                        onSelected: (_) => provider.setAreaFilter(area),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? GolfieColors.ink : GolfieColors.graphite,
                        ),
                        backgroundColor: GolfieColors.white,
                        selectedColor: GolfieColors.mint.withValues(alpha: 0.4),
                        side: BorderSide(
                          color: selected ? GolfieColors.mint : GolfieColors.ash,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GolfieRadii.pill),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Course list
            if (provider.loading && provider.courses.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (provider.filteredCourses.isEmpty)
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.golf_course, size: 40, color: GolfieColors.stone),
                    const SizedBox(height: 8),
                    Text(
                      'No courses in this area yet',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: GolfieColors.stone,
                      ),
                    ),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList.builder(
                  itemCount: provider.filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = provider.filteredCourses[index];
                    return _CourseCard(course: course);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailScreen(course: course),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GolfieColors.white,
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          border: Border.all(color: GolfieColors.ash),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon block
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GolfieColors.skyGradient.colors.first.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(GolfieRadii.lg),
              ),
              child: Icon(Icons.golf_course, color: GolfieColors.azure),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: GolfieColors.ink,
                          ),
                        ),
                      ),
                      if (course.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: GolfieColors.marigold.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FEATURED',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: GolfieColors.graphite,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: GolfieColors.stone,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        course.statsLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GolfieColors.graphite,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        course.greenFeeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GolfieColors.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: GolfieColors.stone),
          ],
        ),
      ),
    );
  }
}
