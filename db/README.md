# Golfie Database Setup

This directory contains SQL migration scripts for the PostgreSQL database used by the Golfie app.

## Overview

The schema includes all tables defined in the PRD:
- `courses` - Golf course information
- `users` - User profiles (extension of Supabase auth.users)
- `tournaments` - Tournament listings
- `registrations` - User tournament registrations
- `leaderboard_entry` - Tournament scores and rankings

## Setup Instructions

### Option 1: Via Supabase Dashboard

1. Log in to your [Supabase project](https://supabase.com/dashboard)
2. Go to **SQL** in the left sidebar
3. Paste the contents of `migrations/001_init_schema.sql`
4. Click **Run**

### Option 2: Via Supabase CLI

Install Supabase CLI: https://supabase.com/docs/cli

```bash
# Initialize local supabase
supabase init

# Link to your project
supabase link --project-id <your-project-id>

# Apply migration
supabase migrate status
supabase migrate push db/migrations/001_init_schema.sql

# Or open SQL editor and run manually
supabase studio
```

### Option 3: Direct PostgreSQL Connection

```bash
psql "host=<host> port=<port> dbname=<dbname> user=<user> password=<password>" -f db/migrations/001_init_schema.sql
```

## Important Notes

### Row Level Security (RLS)

The schema includes RLS policies that enforce data access based on:
- `auth.uid()` - current user ID
- `auth.role()` - user role (admin vs user)

Ensure Supabase JWT auth is properly configured and your client sends the Authorization header with the Bearer token.

### Enums

Custom ENUM types are created to ensure data integrity across all table columns matching the PRD specification.

### Views

Two useful views are provided:
- `tournament_details` - Joins tournaments with courses and counts registrations
- `user_profiles` - Joins users with their registration history

### Functions

Helper functions included:
- `check_tournament_availability()` - Checks if a tournament has space for a user

## Seed Data

Sample seed data is commented out in the main migration file. Uncomment and execute in development only.

## Environment Variables

For the Node.js API (`golfie-api`), configure:

```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key> # For admin operations
DB_HOST=<host>
DB_PORT=<port>
DB_NAME=<dbname>
DB_USER=<user>
DB_PASSWORD=<password>
```

## Integration with Flutter App

The Flutter app uses `supabase_flutter` package. Initialize with environment variables:

```dart
// In main.dart
final _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
final _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

SupabaseWrapper.init(
  baseUrl: _supabaseUrl,
  anonKey: _anonKey,
);
```

Build with:

```bash
dart run \
  --dart-define=SUPABASE_URL=<your_url> \
  --dart-define=SUPABASE_ANON_KEY=<your_anon_key>
```

## Future Migration Strategy

Use numbered sequential filenames:
- `002_add_indexes.sql`
- `003_add_fts.sql`
- `004_ai_features.sql`

Maintain migration order and include rollback instructions where destructive changes are needed.