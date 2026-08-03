# Profile & Settings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add bottom navigation with 4 tabs (Home/News/Tournaments/Profile), a combined Profile+Settings screen, edit profile screen, and logout flow.

**Architecture:** HomeScreen becomes a tabbed shell (IndexedStack + NavigationBar). New `lib/features/profile/` holds ProfileScreen and EditProfileScreen, both reading/writing existing AuthProvider + OnboardingProvider (no new provider). Profile data is local (onboarding prefs), email read from Supabase session.

**Tech Stack:** Flutter, provider, SharedPreferences (via OnboardingProvider), Golfie design system tokens.

---

### Task 1: Add preference toggle method to OnboardingProvider

**Files:**
- Modify: `lib/features/onboarding/providers/onboarding_provider.dart`

- [ ] **Step 1: Add `updatePreferences` method**

Insert after `setLocationAndPreferences` (line ~120):

```dart
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
```

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze lib/features/onboarding/providers/onboarding_provider.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/providers/onboarding_provider.dart
git commit -m "feat(onboarding): add updatePreferences for profile screen toggles"
```

---

### Task 2: Create ProfileScreen

**Files:**
- Create: `lib/features/profile/screens/profile_screen.dart`
- Create: `lib/features/profile/screens/edit_profile_screen.dart`

- [ ] **Step 1: Create profile feature directory**

```bash
mkdir -p lib/features/profile/screens
```

- [ ] **Step 2: Write ProfileScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import 'edit_profile_screen.dart';

/// Combined profile + settings screen. Shows account info from Supabase
/// session, preferences from onboarding, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _displayName(OnboardingProvider onboard, AuthProvider auth) {
    final name = onboard.userName;
    if (name != null && name.trim().isNotEmpty) return name;
    final email = auth.user?.email ?? '';
    return email.split('@').first;
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboard = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GolfieColors.white,
                borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x00000001),
                      blurRadius: 50,
                      offset: const Offset(50, 40)),
                  BoxShadow(
                      color: const Color(0x00000002),
                      blurRadius: 50,
                      offset: const Offset(50, 40)),
                  BoxShadow(
                      color: const Color(0x00000005),
                      blurRadius: 20,
                      offset: const Offset(20, 40)),
                  BoxShadow(
                      color: const Color(0x08000008),
                      blurRadius: 3,
                      offset: const Offset(3, 10)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: GolfieColors.mint.withValues(alpha: 0.3),
                    child: Text(
                      _initials(_displayName(onboard, auth)),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: GolfieColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _displayName(onboard, auth),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: GolfieColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: GolfieColors.stone,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACCOUNT section
            _buildSectionLabel('ACCOUNT'),
            const SizedBox(height: 8),
            _buildListItem(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              trailing: const Icon(Icons.chevron_right, color: GolfieColors.stone),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // PREFERENCES section
            _buildSectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            _buildToggleItem(
              label: 'Nearby tournaments',
              value: onboard.showNearby,
              onChanged: (v) => onboard.updatePreferences(
                showNearby: v,
                emailNotifications: onboard.emailNotifications,
              ),
            ),
            _buildToggleItem(
              label: 'Email notifications',
              value: onboard.emailNotifications,
              onChanged: (v) => onboard.updatePreferences(
                showNearby: onboard.showNearby,
                emailNotifications: v,
              ),
            ),

            const SizedBox(height: 24),

            // ABOUT section
            _buildSectionLabel('ABOUT'),
            const SizedBox(height: 8),
            _buildListItem(
              icon: Icons.info_outline,
              label: 'App version',
              trailing: Text(
                AppConfig.instance.appVersion,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: GolfieColors.stone,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GolfieColors.white,
                  foregroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GolfieRadii.pill),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _confirmLogout(context),
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: GolfieColors.stone,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        border: Border.all(color: GolfieColors.ash),
      ),
      child: ListTile(
        leading: Icon(icon, color: GolfieColors.ink),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: GolfieColors.ink,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        border: Border.all(color: GolfieColors.ash),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: GolfieColors.ink,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: GolfieColors.mint,
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GolfieColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
        ),
        title: Text(
          'Log out?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
        content: Text(
          'You will need to sign in again to access your account.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: GolfieColors.graphite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const _SplashPlaceholder(),
          ),
          (route) => false,
        );
      }
    }
  }
}

/// Minimal placeholder used after logout. Real SplashScreen lives in the
/// auth feature; importing it here couples profile→auth screen. Splash
/// re-checks auth and routes to login.
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Real splash would go here; HomeScreen shell is removed, so any
    // empty scaffold works until app restart. Use actual SplashScreen:
    return const SizedBox.shrink();
  }
}
```

- [ ] **Step 3: Write EditProfileScreen**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../tournament/models/skill_level.dart';
import '../../onboarding/providers/onboarding_provider.dart';

/// Edit name, skill level, and location. Saves to OnboardingProvider.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  SkillLevel? _skillLevel;

  @override
  void initState() {
    super.initState();
    final onboard = context.read<OnboardingProvider>();
    _nameController = TextEditingController(text: onboard.userName ?? '');
    _locationController = TextEditingController(text: onboard.location ?? '');
    _skillLevel = onboard.skillLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboard = context.watch<OnboardingProvider>();
    final canSave = _nameController.text.trim().length >= 2;

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Edit profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            Text(
              'Name',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: GolfieColors.white,
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: GolfieColors.stone,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GolfieRadii.xl),
                  borderSide: BorderSide(color: GolfieColors.ash),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GolfieRadii.xl),
                  borderSide:
                      const BorderSide(color: GolfieColors.ink, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Skill level
            Text(
              'Skill level',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: SkillLevel.values.length,
              itemBuilder: (context, index) {
                final skill = SkillLevel.values[index];
                final selected = _skillLevel == skill;
                return GestureDetector(
                  onTap: () => setState(() => _skillLevel = skill),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? GolfieColors.mint.withValues(alpha: 0.2)
                          : GolfieColors.white,
                      borderRadius: BorderRadius.circular(GolfieRadii.lg),
                      border: Border.all(
                        color: selected ? GolfieColors.mint : GolfieColors.ash,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _skillIcon(skill),
                          color: selected
                              ? GolfieColors.mint
                              : GolfieColors.graphite,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _skillLabel(skill),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: GolfieColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Location field
            Text(
              'Home course or area',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                filled: true,
                fillColor: GolfieColors.white,
                hintText: 'e.g. Pondok Indah, Jakarta',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: GolfieColors.stone,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GolfieRadii.xl),
                  borderSide: BorderSide(color: GolfieColors.ash),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GolfieRadii.xl),
                  borderSide:
                      const BorderSide(color: GolfieColors.ink, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSave ? GolfieColors.ink : GolfieColors.stone,
                  foregroundColor: canSave ? GolfieColors.white : GolfieColors.ink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GolfieRadii.pill),
                  ),
                ),
                onPressed: canSave ? () => _save(onboard) : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _skillIcon(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Icons.golf_course;
      case SkillLevel.casual:
        return Icons.flag;
      case SkillLevel.competitive:
        return Icons.sentiment_very_satisfied;
      case SkillLevel.pro:
        return Icons.star;
    }
  }

  String _skillLabel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.casual:
        return 'Casual';
      case SkillLevel.competitive:
        return 'Competitive';
      case SkillLevel.pro:
        return 'Pro';
    }
  }

  void _save(OnboardingProvider onboard) {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();

    onboard.setProfileInfo(
      name: name,
      level: _skillLevel ?? SkillLevel.beginner,
    );
    onboard.setLocationAndPreferences(
      location: location,
      showNearby: onboard.showNearby,
      emailNotifications: onboard.emailNotifications,
    );

    if (mounted) Navigator.pop(context);
  }
}
```

- [ ] **Step 4: Fix logout navigation — use real SplashScreen**

In `profile_screen.dart`, replace the `_SplashPlaceholder` usage with the real `SplashScreen`:

```dart
import '../../auth/screens/splash_screen.dart';
```

And in `_confirmLogout`, replace:

```dart
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const _SplashPlaceholder(),
          ),
          (route) => false,
        );
```

with:

```dart
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const SplashScreen(),
          ),
          (route) => false,
        );
```

Remove the `_SplashPlaceholder` class entirely.

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/features/profile/`
Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/features/profile/
git commit -m "feat(profile): add ProfileScreen + EditProfileScreen

Combined profile+settings: account header, edit profile, preference
toggles, app version, logout with confirm dialog. Edit screen saves
name/skill/location to OnboardingProvider."
```

---

### Task 3: Restructure HomeScreen with bottom nav

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Read current HomeScreen fully**

```bash
cat lib/screens/home_screen.dart
```

- [ ] **Step 2: Convert HomeScreen to tab shell**

Replace the `HomeScreen` class with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../berita/screens/berita_list_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../providers/app_state.dart';
import '../tournament/screens/tournament_list_screen.dart';
import '../widgets/golfie/golfie_index.dart';
import 'caddy_tips_screen.dart';
import 'admin_moderation_screen.dart';
import 'submit_tournament_screen.dart';

/// Root shell with 4 tabs: Home, News, Tournaments, Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _HomeTab(),
          BeritaListScreen(),
          TournamentListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        backgroundColor: GolfieColors.white,
        indicatorColor: GolfieColors.mint.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.golf_course_outlined),
            selectedIcon: Icon(Icons.golf_course),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// The original HomeScreen content, extracted as the Home tab.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    // Original HomeScreen build() body goes here verbatim
    // (Scaffold with AppBar actions, FAB, GolfieHero, etc.)
  }
}
```

- [ ] **Step 3: Move existing HomeScreen body into _HomeTab**

The original `HomeScreen.build()` content (AppBar with caddy/admin/popup actions, FAB, SingleChildScrollView body with GolfieHero + pill buttons) goes verbatim into `_HomeTab.build()`. Keep all imports from the original file. Delete the old `HomeScreen` class and its unused `build` body.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze lib/screens/home_screen.dart`
Expected: No issues. (Unused imports removed if any.)

- [ ] **Step 5: Run widget tests**

Run: `flutter test test/screens/`
Expected: Existing home_screen tests pass (they may reference `HomeScreen` — if a test pumps `HomeScreen` and expects specific widgets, it still works since HomeScreen still exists as the shell).

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat(nav): restructure HomeScreen as 4-tab shell (IndexedStack + NavigationBar)"
```

---

### Task 4: Full verification

**Files:** None (verification only)

- [ ] **Step 1: Full analyzer**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: Existing tests pass (login_screen_test has 2 known pre-existing failures unrelated to this change).

- [ ] **Step 3: Push branch**

```bash
git push -u origin feature/profile-settings
```

- [ ] **Step 4: Manual test checklist**

```text
1. App opens → bottom nav shows 4 tabs (Home, News, Tournaments, Profile).
2. Switch tabs → state preserved (IndexedStack).
3. Profile tab → name/email from auth + onboarding shown.
4. Toggle nearby/email → persists after app restart.
5. Edit profile → change name/skill/location → Save → ProfileScreen updates.
6. Log out → confirm dialog → session cleared → SplashScreen → LoginScreen.
```
