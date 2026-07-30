---
name: golfie-database-setup
description: Database schema and migration files created for Golfie Flutter project using Supabase/PostgreSQL
metadata:
  type: project
  reference: true
---

## Database Schema Created

### Location: `/home/kiyaya/kiyadev/kbvs-golf/db/migrations/001_init_schema.sql`

#### Tables Created:
1. **courses** - Golf course metadata (name, location, coordinates, facilities)
2. **users** - User profile extension referencing `auth.users` from Supabase (username, skill level, handicap, role)
3. **tournaments** - Tournament listings with format, dates, pricing, capacity, status
4. **registrations** - User tournament sign-ups with confirmed/withdrawn status
5. **leaderboard_entry** - Tournament scores and rankings

#### Key Features:
- Custom ENUM types matching PRD specifications (`skill_level`, `tournament_format`, etc.)
- Row Level Security (RLS) policies for data access control — all tables fully protected
- Auto-updating timestamps via triggers on all tables
- Full-text search index on tournament names/descriptions
- Useful views: `tournament_details`, `user_profiles`
- Helper function: `check_tournament_availability()`

### Complete RLS Policies Applied (2026-07-30):

**Users Table:**
- `users_select_policy`: Authenticated users can read their own profile
- `users_admin_select_policy`: Admins can view all user profiles
- `users_insert_policy`: New users insert their own record after signup
- `users_update_policy`: Users can update their own profile
- `users_admin_update_policy`: Admins can update any user

**Tournaments Table:**
- `tournaments_select_policy`: Public read access to all tournaments
- `tournaments_insert_policy`: Authenticated users can create tournaments
- `tournaments_update_policy`: Users can only update their own tournaments
- `tournaments_delete_policy`: Users can only delete their own tournaments
- `tournaments_admin_policy`: Admins can manage any tournament

**Courses Table:**
- `courses_policy`: Public read access
- `courses_insert_policy`: Authenticated insert capability
- `courses_update_policy`, `courses_delete_policy`: Admin-only write access

**Registrations & Leaderboard:** Comprehensive RLS for user-specific access with admin overrides

## Integration Notes

### Supabase Auth Setup
- Supabase auto-creates `auth.users` table
- Our `users` table links via `id REFERENCES auth.users(id) ON DELETE CASCADE`
- RLS uses `auth.uid()` for session-based authorization, `auth.role()` for admin checks

### Flutter Client Configuration
Initialize via environment variables at compile time:

```dart
--dart-define=SUPABASE_URL=<project-url> \
--dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

Your app already has `SupabaseWrapper` in `lib/features/auth/widgets/supabase_wrapper.dart` that handles this.

### Auth Provider
See `lib/features/auth/providers/auth_provider.dart` for full auth management:
- signUp, signIn, signOut
- forgotPassword, resetPassword
- Error handling with user-friendly messages
- State management with Provider

### Required Credentials (from your request):
- **URL**: `https://rvlvnvukmbwkpooilkcq.supabase.co`
- **Anon Key**: `sb_publishable_zkcIHWfdDsraMrVhFRZzcQ_22zGDqOS`

## Next Steps

1. **Run Migration** on actual Supabase project:
   ```bash
   # Via CLI
   supabase db push --file db/migrations/001_init_schema.sql
   
   # Or via Supabase Dashboard SQL Editor
   ```

2. **Enable Authentication** in Supabase dashboard (Email/Password + Google OAuth)

3. **Seed Sample Data** (uncomment the seed section in the SQL file if needed)

4. **For production**, add `SUPABASE_SERVICE_ROLE_KEY` securely to backend environment

5. **Implement Golfie API** (golfie-api directory) with Prisma ORM connected to this DB

## Memory References

[[Golfie rebrand decisions]] - package name, font choices
[[Auth Onboarding Design Spec]] - UI design tokens and flows
[[Auth Onboarding Implementation Plan]] - Phase-by-phase roadmap
