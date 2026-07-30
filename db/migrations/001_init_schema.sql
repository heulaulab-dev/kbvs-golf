-- ============================================================
-- Golfie Database Schema - Initial Migration v1.0
-- Generated: 2026-07-30
-- Stack: PostgreSQL 15+ / Supabase
-- ============================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE tournament_format AS ENUM (
    'match-play',
    'stableford',
    'scramble',
    'best-ball',
    'championship'
);

CREATE TYPE skill_level AS ENUM (
    'beginner',
    'casual',
    'competitive',
    'pro'
);

CREATE TYPE tournament_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'FULL'
);

CREATE TYPE registration_status AS ENUM (
    'CONFIRMED',
    'WITHDRAWN'
);

CREATE TYPE user_role AS ENUM (
    'user',
    'admin'
);

-- ============================================================
-- COURSES TABLE
-- ============================================================

CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    location VARCHAR(100) NOT NULL,
    latitude FLOAT,
    longitude FLOAT,
    par INT,
    length_yards INT,
    facility_notes TEXT,
    image_url VARCHAR(512),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    INDEX idx_courses_location (location),
    INDEX idx_courses_geo (latitude, longitude)
);

-- ============================================================
-- USERS TABLE
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(12) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL REFERENCES auth.users(email) ON DELETE CASCADE,
    skill_level skill_level DEFAULT 'beginner',
    handicap INT CHECK (handicap BETWEEN 0 AND 50),
    role user_role DEFAULT 'user',
    avatar_url VARCHAR(512),
    ai_opt_in BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT chk_username_format CHECK (username ~ '^[a-zA-Z0-9_]{3,12}$'),
    CONSTRAINT chk_handicap_range CHECK (handicap IS NULL OR (handicap >= 0 AND handicap <= 50))
);

-- ============================================================
-- TOURNAMENTS TABLE
-- ============================================================

CREATE TABLE tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    format tournament_format NOT NULL,
    min_skill skill_level NOT NULL,
    max_fee_idr INT NOT NULL CHECK (max_fee_idr >= 0),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status tournament_status DEFAULT 'PENDING',
    max_capacity INT DEFAULT 20 CHECK (max_capacity > 0 AND max_capacity <= 200),
    is_featured BOOLEAN DEFAULT FALSE,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT chk_dates_valid CHECK (end_date > start_date),
    CONSTRAINT chk_fee_positive CHECK (max_fee_idr >= 0),

    INDEX idx_tournaments_name (name),
    INDEX idx_tournaments_course (course_id),
    INDEX idx_tournaments_status (status),
    INDEX idx_tournaments_start_date (start_date),
    INDEX idx_tournaments_format (format),
    INDEX idx_tournaments_min_skill (min_skill),
    INDEX idx_tournaments_featured (is_featured),
    INDEX idx_tournaments_search (to_tsvector('english', COALESCE(name, '') || ' ' || COALESCE(description, '')))
);

-- ============================================================
-- REGISTRATIONS TABLE
-- ============================================================

CREATE TABLE registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    registered_at TIMESTAMPTZ DEFAULT NOW(),
    status registration_status DEFAULT 'CONFIRMED',
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (tournament_id, user_id),

    CHECK (registered_at < (SELECT end_date FROM tournaments WHERE id = tournament_id)),

    INDEX idx_registrations_user (user_id),
    INDEX idx_registrations_tournament (tournament_id),
    INDEX idx_registrations_status (status)
);

-- ============================================================
-- LEADERBOARD TABLE
-- ============================================================

CREATE TABLE leaderboard_entry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    round1_score INT CHECK (round1_score BETWEEN 0 AND 100 OR round1_score IS NULL),
    round2_score INT CHECK (round2_score BETWEEN 0 AND 100 OR round2_score IS NULL),
    total_score INT CHECK (total_score BETWEEN 0 AND 200 OR total_score IS NULL),
    rank INT CHECK (rank > 0 OR rank IS NULL),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (tournament_id, user_id),

    INDEX idx_leaderboard_tournament (tournament_id),
    INDEX idx_leaderboard_user (user_id),
    INDEX idx_leaderboard_scores (total_score, rank)
);

-- ============================================================
-- TRIGGER: Auto-update updated_at column
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournaments_updated_at
BEFORE UPDATE ON tournaments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at
BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at
BEFORE UPDATE ON registrations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leaderboard_updated_at
BEFORE UPDATE ON leaderboard_entry FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entry ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------
-- COURSES RLS Policies
-- -----------------------------------------------------------

-- Public read access to all courses
CREATE POLICY courses_policy ON courses
  FOR SELECT
  USING (true);

-- Authenticated users can insert own course entries
CREATE POLICY courses_insert_policy ON courses
  FOR INSERT
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- Admins only can update or delete courses
CREATE POLICY courses_update_policy ON courses
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

CREATE POLICY courses_delete_policy ON courses
  FOR DELETE
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- -----------------------------------------------------------
-- USERS RLS Policies
-- -----------------------------------------------------------

-- Users can read their own profile and see other usernames/emails
CREATE POLICY users_select_policy ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Only admins can read all user profiles
CREATE POLICY users_admin_select_policy ON users
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- New users can only read/write their own record after signup
CREATE POLICY users_insert_policy ON users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY users_update_policy ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Admins can update any user
CREATE POLICY users_admin_update_policy ON users
  FOR UPDATE
  TO authenticated
  USING ((SELECT auth.role()) = 'admin')
  WITH CHECK (auth.uid() = id);

-- -----------------------------------------------------------
-- TOURNAMENTS RLS Policies
-- -----------------------------------------------------------

-- Public read access to tournaments (all users can view)
CREATE POLICY tournaments_select_policy ON tournaments
  FOR SELECT
  USING (true);

-- Authenticated users can create tournaments
CREATE POLICY tournaments_insert_policy ON tournaments
  FOR INSERT
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- Users can only update/delete their own tournaments
CREATE POLICY tournaments_update_policy ON tournaments
  FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

CREATE POLICY tournaments_delete_policy ON tournaments
  FOR DELETE
  TO authenticated
  USING (created_by = auth.uid());

-- Admins can manage any tournament
CREATE POLICY tournaments_admin_policy ON tournaments
  FOR ALL
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- -----------------------------------------------------------
-- REGISTRATIONS RLS Policies
-- -----------------------------------------------------------

-- Users can view their own registrations
CREATE POLICY registrations_select_policy ON registrations
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Admins can view all registrations
CREATE POLICY registrations_admin_select_policy ON registrations
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- Users can register for tournaments (check capacity via trigger/function)
CREATE POLICY registrations_insert_policy ON registrations
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users can only update their own registration status
CREATE POLICY registrations_update_policy ON registrations
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Admins can manage all registrations
CREATE POLICY registrations_admin_policy ON registrations
  FOR ALL
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- -----------------------------------------------------------
-- LEADERBOARD RLS Policies
-- -----------------------------------------------------------

-- Users can view their own leaderboard entries
CREATE POLICY leaderboard_select_policy ON leaderboard_entry
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Admins can view all leaderboard entries
CREATE POLICY leaderboard_admin_select_policy ON leaderboard_entry
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- Users can update their own scores
CREATE POLICY leaderboard_update_policy ON leaderboard_entry
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Admins can manage all leaderboard entries
CREATE POLICY leaderboard_admin_policy ON leaderboard_entry
  FOR ALL
  TO authenticated
  USING ((SELECT auth.role()) = 'admin');

-- -----------------------------------------------------------
-- VIEW RLS Policies
-- -----------------------------------------------------------

-- Protect views by denying direct access, require policies through base tables
-- Note: Views bypass RLS by default. Restrict via base table policies.

-- ============================================================
-- FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION check_tournament_availability(tournament_id UUID, user_id UUID)
RETURNS TABLE(available BOOLEAN, message TEXT, current_count INT, capacity INT) AS $$
DECLARE
    reg_count INT;
    cap INT;
BEGIN
    SELECT COUNT(*), max_capacity INTO reg_count, cap
    FROM tournaments t
    JOIN registrations r ON t.id = r.tournament_id
    WHERE t.id = tournament_id AND r.status = 'CONFIRMED'
    GROUP BY t.max_capacity;

    IF NOT FOUND THEN
        available := FALSE;
        message := 'Tournament not found';
        current_count := 0;
        capacity := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    SELECT status INTO reg_count
    FROM registrations
    WHERE tournament_id = tournament_id AND user_id = user_id;

    IF FOUND AND reg_count = 'CONFIRMED' THEN
        available := FALSE;
        message := 'You are already registered';
        current_count := reg_count;
        capacity := cap;
        RETURN NEXT;
        RETURN;
    ELSIF reg_count < cap THEN
        available := TRUE;
        message := 'Available';
        current_count := reg_count;
        capacity := cap;
        RETURN NEXT;
    ELSE
        available := FALSE;
        message := 'Full';
        current_count := reg_count;
        capacity := cap;
        RETURN NEXT;
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SEED DATA (development only - uncomment to run)
-- ============================================================

/*
INSERT INTO courses (name, location, latitude, longitude, par, length_yards, facility_notes, image_url) VALUES
('Emeralda Golf Club', 'South Jakarta', -6.3833, 106.7667, 18, 7200, 'Full service clubhouse, pro shop, restaurant', 'https://example.com/emerald.jpg'),
('Royale Jakarta Golf Club', 'Central Jakarta', -6.3900, 106.8000, 18, 7150, 'Premium facilities, ocean view', 'https://example.com/royale.jpg'),
('Menteng Country Club', 'Central Jakarta', -6.3750, 106.8167, 18, 6980, 'Historic club, family-friendly', 'https://example.com/menteng.jpg');

INSERT INTO users (id, username, email, skill_level, role, avatar_url) VALUES
(gen_random_uuid(), 'admin_golf', 'admin@golfie.app', 'pro', 'admin', 'https://example.com/admin.jpg');

INSERT INTO tournaments (name, description, course_id, format, min_skill, max_fee_idr, start_date, end_date, status, max_capacity, is_featured, created_by) VALUES
('Jakarta Scramble Spring Open', 'Team scramble format with prizes for top 3', (SELECT id FROM courses WHERE name = 'Emeralda Golf Club'), 'scramble', 'beginner', 250000, '2026-08-15 08:00:00+00', '2026-08-15 17:00:00+00', 'APPROVED', 20, TRUE, (SELECT id FROM users WHERE username = 'admin_golf'));
*/

-- ============================================================
-- NOTES
-- ============================================================
-- Apply this migration via Supabase Dashboard SQL Editor or:
--   supabase db push --file db/migrations/001_init_schema.sql
-- RLS policies defined for secure data access
-- Use service role key for admin operations from backend
