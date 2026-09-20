CREATE TABLE IF NOT EXISTS section_passes (
    id VARCHAR(255) PRIMARY KEY,
    hash VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS fcm_tokens (
    token VARCHAR(255) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS restricted_devices (
    id VARCHAR(255) PRIMARY KEY,
    deviceId VARCHAR(255),
    name VARCHAR(255),
    phone VARCHAR(20),
    dateRestricted TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    uid VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    phone VARCHAR(20),
    displayName VARCHAR(255),
    year VARCHAR(50),
    sem VARCHAR(50),
    college VARCHAR(255),
    stream VARCHAR(100),
    passHash VARCHAR(255),
    totalSessions INTEGER DEFAULT 0,
    dailySessions INTEGER DEFAULT 0,
    lastResetDate VARCHAR(50),
    role VARCHAR(50) DEFAULT 'user',
    status VARCHAR(50) DEFAULT 'active',
    deviceId VARCHAR(255),
    regDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS course_access (
    id VARCHAR(255) PRIMARY KEY,
    courseId VARCHAR(255),
    userId VARCHAR(255),
    grantedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_views (
    id VARCHAR(255) PRIMARY KEY,
    statusId VARCHAR(255),
    uid VARCHAR(255),
    name VARCHAR(255),
    lastViewedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_view_events (
    id VARCHAR(255) PRIMARY KEY,
    statusId VARCHAR(255),
    uid VARCHAR(255),
    name VARCHAR(255),
    viewedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_likes (
    id VARCHAR(255) PRIMARY KEY,
    statusId VARCHAR(255),
    uid VARCHAR(255),
    name VARCHAR(255),
    likedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_votes (
    id VARCHAR(255) PRIMARY KEY,
    statusId VARCHAR(255),
    uid VARCHAR(255),
    name VARCHAR(255),
    optionIndex INTEGER,
    optionText TEXT,
    votedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_replies (
    id VARCHAR(255) PRIMARY KEY,
    statusId VARCHAR(255),
    uid VARCHAR(255),
    name VARCHAR(255),
    reply TEXT,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS statuses (
    id VARCHAR(255) PRIMARY KEY,
    createdBy VARCHAR(255),
    payload JSONB,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_likes (
    id VARCHAR(255) PRIMARY KEY,
    count INTEGER DEFAULT 0,
    userId VARCHAR(255),
    targetId VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS course_likes (
    id VARCHAR(255) PRIMARY KEY,
    count INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS course_lecture_secrets (
    id VARCHAR(255) PRIMARY KEY,
    secretData JSONB
);

CREATE TABLE IF NOT EXISTS course_passwords (
    id VARCHAR(255) PRIMARY KEY,
    passwordHash VARCHAR(255),
    usageCount INTEGER DEFAULT 0,
    maxUsers INTEGER,
    lastUsedAt TIMESTAMPTZ,
    isActive BOOLEAN DEFAULT true,
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedBy VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS course_progress (
    id VARCHAR(255) PRIMARY KEY,
    userId VARCHAR(255),
    lectureId VARCHAR(255),
    completedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    thumbnail VARCHAR(255),
    displayOrder INTEGER DEFAULT 0,
    assignedDonationId VARCHAR(255),
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    visibility VARCHAR(50) DEFAULT 'public'
);

CREATE TABLE IF NOT EXISTS donations (
    id VARCHAR(255) PRIMARY KEY,
    displayOrder INTEGER DEFAULT 0,
    donorName VARCHAR(255),
    amount DECIMAL(10,2),
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_subjects (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    rating DECIMAL(3,2) DEFAULT 0,
    ratingCount INTEGER DEFAULT 0,
    displayOrder INTEGER DEFAULT 0,
    subjectAdmins TEXT[],
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS course_modules (
    id VARCHAR(255) PRIMARY KEY,
    subjectId VARCHAR(255),
    title VARCHAR(255),
    displayOrder INTEGER DEFAULT 0,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_lectures (
    id VARCHAR(255) PRIMARY KEY,
    moduleId VARCHAR(255),
    title VARCHAR(255),
    videoUrl VARCHAR(255),
    isPartition BOOLEAN DEFAULT FALSE,
    displayOrder INTEGER DEFAULT 0,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_notes (
    id VARCHAR(255) PRIMARY KEY,
    lectureId VARCHAR(255),
    title VARCHAR(255),
    pdfLink VARCHAR(255),
    moduleId VARCHAR(255),
    isFinalNote BOOLEAN DEFAULT FALSE,
    driveLink VARCHAR(255),
    displayOrder INTEGER DEFAULT 0,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_notatures (
    id VARCHAR(255) PRIMARY KEY,
    lectureId VARCHAR(255),
    title VARCHAR(255),
    pdfLink VARCHAR(255),
    videoUrl VARCHAR(255),
    isPartition BOOLEAN DEFAULT FALSE,
    displayOrder INTEGER DEFAULT 0,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS donor_names (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    timestamp BIGINT
);

CREATE TABLE IF NOT EXISTS app_settings (
    id VARCHAR(255) PRIMARY KEY,
    enabled BOOLEAN DEFAULT true,
    type VARCHAR(50),
    mode VARCHAR(50),
    active BOOLEAN,
    img VARCHAR(255),
    title VARCHAR(255),
    body TEXT,
    musicURL VARCHAR(255),
    link VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS share_analytics (
    id VARCHAR(255) PRIMARY KEY,
    eventId VARCHAR(255),
    userId VARCHAR(255),
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    data JSONB
);

CREATE TABLE IF NOT EXISTS mockTests (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    isActive BOOLEAN DEFAULT false,
    targetType VARCHAR(50),
    semType VARCHAR(50),
    timerMinutes INTEGER,
    allowClose BOOLEAN DEFAULT false,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mockTestSubmissions (
    id VARCHAR(255) PRIMARY KEY,
    mockTestId VARCHAR(255),
    userId VARCHAR(255),
    name VARCHAR(255),
    mobile VARCHAR(20),
    year VARCHAR(50),
    semType VARCHAR(50),
    pdfLink VARCHAR(255),
    submittedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    marks INTEGER
);

CREATE TABLE IF NOT EXISTS videos (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    thumbnail VARCHAR(255),
    adminOrder INTEGER DEFAULT 0,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    subject VARCHAR(255),
    topic VARCHAR(255),
    subtopic VARCHAR(255),
    playlistUrl VARCHAR(255),
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gate (
    id VARCHAR(255) PRIMARY KEY,
    branch VARCHAR(100),
    title VARCHAR(255),
    syllabusLink VARCHAR(255),
    notesLink VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customItems (
    id VARCHAR(255) PRIMARY KEY,
    sectionSlug VARCHAR(255),
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    link VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS links (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    url VARCHAR(255),
    stream VARCHAR(100),
    category VARCHAR(100) DEFAULT 'General',
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
    id VARCHAR(255) PRIMARY KEY,
    streams TEXT[],
    stream VARCHAR(255),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    cover VARCHAR(255),
    pdf VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ca3_papers (
    id VARCHAR(255) PRIMARY KEY,
    "caType" VARCHAR(50) DEFAULT 'CA1',
    "collegeName" VARCHAR(255),
    subject VARCHAR(255),
    "teacherName" VARCHAR(255),
    stream VARCHAR(100),
    "yearSem" VARCHAR(50),
    "paperTitle" VARCHAR(255),
    description TEXT,
    "driveLink" VARCHAR(255),
    "uploadedBy" VARCHAR(255),
    "uploaderId" VARCHAR(255),
    "uploadType" VARCHAR(50) DEFAULT 'User',
    approved BOOLEAN DEFAULT false,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS notes (
    id VARCHAR(255) PRIMARY KEY,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    link VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS answers (
    id VARCHAR(255) PRIMARY KEY,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    link VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pyqs (
    id VARCHAR(255) PRIMARY KEY,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    subject VARCHAR(255),
    examYear VARCHAR(50),
    link VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS organizers (
    id VARCHAR(255) PRIMARY KEY,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    link VARCHAR(255),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS suggestions (
    id VARCHAR(255) PRIMARY KEY,
    stream VARCHAR(100),
    year VARCHAR(50),
    sem VARCHAR(50),
    title VARCHAR(255),
    link VARCHAR(255),
    body TEXT,
    date VARCHAR(50),
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS streams (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customSections (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    slug VARCHAR(255),
    visible BOOLEAN DEFAULT false,
    visibility VARCHAR(50) DEFAULT 'public',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS doubts (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    subject VARCHAR(255),
    question TEXT,
    answer TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS settings (
    id VARCHAR(255) PRIMARY KEY,
    type VARCHAR(50),
    mode VARCHAR(50),
    active BOOLEAN,
    img VARCHAR(255),
    title VARCHAR(255),
    body TEXT,
    musicURL VARCHAR(255),
    link VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS subject_ratings (
    id VARCHAR(255) PRIMARY KEY,
    subjectId VARCHAR(255),
    userId VARCHAR(255),
    rating INTEGER,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- Row Level Security (RLS) Open Policies
-- This mimics Firestore's open database behavior by allowing all operations.
ALTER TABLE section_passes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on section_passes" ON section_passes;
-- Secure Policy for section_passes
CREATE POLICY "Restricted Access to Authenticated Users" ON section_passes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on fcm_tokens" ON fcm_tokens;
-- Secure Policy for fcm_tokens
CREATE POLICY "Restricted Access to Authenticated Users" ON fcm_tokens FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE restricted_devices ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on restricted_devices" ON restricted_devices;
-- Secure Policy for restricted_devices
CREATE POLICY "Restricted Access to Authenticated Users" ON restricted_devices FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on users" ON users;
-- Secure Policy for users
CREATE POLICY "Restricted Access to Authenticated Users" ON users FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_access ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_access" ON course_access;
-- Secure Policy for course_access
CREATE POLICY "Restricted Access to Authenticated Users" ON course_access FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE status_views ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on status_views" ON status_views;
-- Secure Policy for status_views
CREATE POLICY "Restricted Access to Authenticated Users" ON status_views FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE status_view_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on status_view_events" ON status_view_events;
-- Secure Policy for status_view_events
CREATE POLICY "Restricted Access to Authenticated Users" ON status_view_events FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE status_likes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on status_likes" ON status_likes;
-- Secure Policy for status_likes
CREATE POLICY "Restricted Access to Authenticated Users" ON status_likes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE status_votes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on status_votes" ON status_votes;
-- Secure Policy for status_votes
CREATE POLICY "Restricted Access to Authenticated Users" ON status_votes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE status_replies ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on status_replies" ON status_replies;
-- Secure Policy for status_replies
CREATE POLICY "Restricted Access to Authenticated Users" ON status_replies FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE statuses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on statuses" ON statuses;
-- Secure Policy for statuses
CREATE POLICY "Restricted Access to Authenticated Users" ON statuses FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE user_likes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on user_likes" ON user_likes;
-- Secure Policy for user_likes
CREATE POLICY "Restricted Access to Authenticated Users" ON user_likes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_likes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_likes" ON course_likes;
-- Secure Policy for course_likes
CREATE POLICY "Restricted Access to Authenticated Users" ON course_likes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_lecture_secrets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_lecture_secrets" ON course_lecture_secrets;
-- Secure Policy for course_lecture_secrets
CREATE POLICY "Restricted Access to Authenticated Users" ON course_lecture_secrets FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_passwords ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_passwords" ON course_passwords;
-- Secure Policy for course_passwords
CREATE POLICY "Restricted Access to Authenticated Users" ON course_passwords FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_progress ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_progress" ON course_progress;
-- Secure Policy for course_progress
CREATE POLICY "Restricted Access to Authenticated Users" ON course_progress FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on courses" ON courses;
-- Public Read Access for courses
CREATE POLICY "Public Read Access" ON courses FOR SELECT USING (true);
-- Restricted Write Access for courses
CREATE POLICY "Restricted Write Access" ON courses FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on donations" ON donations;
-- Secure Policy for donations
CREATE POLICY "Restricted Access to Authenticated Users" ON donations FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_subjects ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_subjects" ON course_subjects;
-- Public Read Access for course_subjects
CREATE POLICY "Public Read Access" ON course_subjects FOR SELECT USING (true);
-- Restricted Write Access for course_subjects
CREATE POLICY "Restricted Write Access" ON course_subjects FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_modules" ON course_modules;
-- Secure Policy for course_modules
CREATE POLICY "Restricted Access to Authenticated Users" ON course_modules FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_lectures ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_lectures" ON course_lectures;
-- Secure Policy for course_lectures
CREATE POLICY "Restricted Access to Authenticated Users" ON course_lectures FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_notes" ON course_notes;
-- Secure Policy for course_notes
CREATE POLICY "Restricted Access to Authenticated Users" ON course_notes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE course_notatures ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on course_notatures" ON course_notatures;
-- Secure Policy for course_notatures
CREATE POLICY "Restricted Access to Authenticated Users" ON course_notatures FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE donor_names ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on donor_names" ON donor_names;
-- Secure Policy for donor_names
CREATE POLICY "Restricted Access to Authenticated Users" ON donor_names FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on app_settings" ON app_settings;
-- Public Read Access for app_settings
CREATE POLICY "Public Read Access" ON app_settings FOR SELECT USING (true);
-- Restricted Write Access for app_settings
CREATE POLICY "Restricted Write Access" ON app_settings FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE share_analytics ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on share_analytics" ON share_analytics;
-- Secure Policy for share_analytics
CREATE POLICY "Restricted Access to Authenticated Users" ON share_analytics FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE mockTests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on mockTests" ON mockTests;
-- Secure Policy for mockTests
CREATE POLICY "Restricted Access to Authenticated Users" ON mockTests FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE mockTestSubmissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on mockTestSubmissions" ON mockTestSubmissions;
-- Secure Policy for mockTestSubmissions
CREATE POLICY "Restricted Access to Authenticated Users" ON mockTestSubmissions FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on videos" ON videos;
-- Secure Policy for videos
CREATE POLICY "Restricted Access to Authenticated Users" ON videos FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE gate ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on gate" ON gate;
-- Public Read Access for gate
CREATE POLICY "Public Read Access" ON gate FOR SELECT USING (true);
-- Restricted Write Access for gate
CREATE POLICY "Restricted Write Access" ON gate FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE customItems ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on customItems" ON customItems;
-- Secure Policy for customItems
CREATE POLICY "Restricted Access to Authenticated Users" ON customItems FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE links ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on links" ON links;
-- Secure Policy for links
CREATE POLICY "Restricted Access to Authenticated Users" ON links FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on books" ON books;
-- Secure Policy for books
CREATE POLICY "Restricted Access to Authenticated Users" ON books FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE ca3_papers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on ca3_papers" ON ca3_papers;
-- Secure Policy for ca3_papers
CREATE POLICY "Restricted Access to Authenticated Users" ON ca3_papers FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on notes" ON notes;
-- Secure Policy for notes
CREATE POLICY "Restricted Access to Authenticated Users" ON notes FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on answers" ON answers;
-- Secure Policy for answers
CREATE POLICY "Restricted Access to Authenticated Users" ON answers FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE pyqs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on pyqs" ON pyqs;
-- Secure Policy for pyqs
CREATE POLICY "Restricted Access to Authenticated Users" ON pyqs FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE organizers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on organizers" ON organizers;
-- Secure Policy for organizers
CREATE POLICY "Restricted Access to Authenticated Users" ON organizers FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on suggestions" ON suggestions;
-- Secure Policy for suggestions
CREATE POLICY "Restricted Access to Authenticated Users" ON suggestions FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE streams ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on streams" ON streams;
-- Public Read Access for streams
CREATE POLICY "Public Read Access" ON streams FOR SELECT USING (true);
-- Restricted Write Access for streams
CREATE POLICY "Restricted Write Access" ON streams FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE customSections ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on customSections" ON customSections;
-- Secure Policy for customSections
CREATE POLICY "Restricted Access to Authenticated Users" ON customSections FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE doubts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on doubts" ON doubts;
-- Secure Policy for doubts
CREATE POLICY "Restricted Access to Authenticated Users" ON doubts FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on settings" ON settings;
-- Public Read Access for settings
CREATE POLICY "Public Read Access" ON settings FOR SELECT USING (true);
-- Restricted Write Access for settings
CREATE POLICY "Restricted Write Access" ON settings FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
ALTER TABLE subject_ratings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on subject_ratings" ON subject_ratings;
-- Public Read Access for subject_ratings
CREATE POLICY "Public Read Access" ON subject_ratings FOR SELECT USING (true);
-- Restricted Write Access for subject_ratings
CREATE POLICY "Restricted Write Access" ON subject_ratings FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);


-- Realtime Publication
-- Enable realtime for all tables to fix data retrieval immediately appearing without refresh
ALTER PUBLICATION supabase_realtime ADD TABLE section_passes;
ALTER PUBLICATION supabase_realtime ADD TABLE fcm_tokens;
ALTER PUBLICATION supabase_realtime ADD TABLE restricted_devices;
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE course_access;
ALTER PUBLICATION supabase_realtime ADD TABLE status_views;
ALTER PUBLICATION supabase_realtime ADD TABLE status_view_events;
ALTER PUBLICATION supabase_realtime ADD TABLE status_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE status_votes;
ALTER PUBLICATION supabase_realtime ADD TABLE status_replies;
ALTER PUBLICATION supabase_realtime ADD TABLE statuses;
ALTER PUBLICATION supabase_realtime ADD TABLE user_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE course_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE course_lecture_secrets;
ALTER PUBLICATION supabase_realtime ADD TABLE course_passwords;
ALTER PUBLICATION supabase_realtime ADD TABLE course_progress;
ALTER PUBLICATION supabase_realtime ADD TABLE courses;
ALTER PUBLICATION supabase_realtime ADD TABLE donations;
ALTER PUBLICATION supabase_realtime ADD TABLE course_subjects;
ALTER PUBLICATION supabase_realtime ADD TABLE course_modules;
ALTER PUBLICATION supabase_realtime ADD TABLE course_lectures;
ALTER PUBLICATION supabase_realtime ADD TABLE course_notes;
ALTER PUBLICATION supabase_realtime ADD TABLE course_notatures;
ALTER PUBLICATION supabase_realtime ADD TABLE donor_names;
ALTER PUBLICATION supabase_realtime ADD TABLE app_settings;
ALTER PUBLICATION supabase_realtime ADD TABLE share_analytics;
ALTER PUBLICATION supabase_realtime ADD TABLE mockTests;
ALTER PUBLICATION supabase_realtime ADD TABLE mockTestSubmissions;
ALTER PUBLICATION supabase_realtime ADD TABLE videos;
ALTER PUBLICATION supabase_realtime ADD TABLE gate;
ALTER PUBLICATION supabase_realtime ADD TABLE customItems;
ALTER PUBLICATION supabase_realtime ADD TABLE links;
ALTER PUBLICATION supabase_realtime ADD TABLE books;
ALTER PUBLICATION supabase_realtime ADD TABLE ca3_papers;
ALTER PUBLICATION supabase_realtime ADD TABLE notes;
ALTER PUBLICATION supabase_realtime ADD TABLE answers;
ALTER PUBLICATION supabase_realtime ADD TABLE pyqs;
ALTER PUBLICATION supabase_realtime ADD TABLE organizers;
ALTER PUBLICATION supabase_realtime ADD TABLE suggestions;
ALTER PUBLICATION supabase_realtime ADD TABLE streams;
ALTER PUBLICATION supabase_realtime ADD TABLE customSections;
ALTER PUBLICATION supabase_realtime ADD TABLE doubts;
ALTER PUBLICATION supabase_realtime ADD TABLE settings;
ALTER PUBLICATION supabase_realtime ADD TABLE subject_ratings;
\n\n-- Added for Course partitons\nALTER TABLE courses ADD COLUMN IF NOT EXISTS year VARCHAR(50);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS department VARCHAR(50);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS banner VARCHAR(255);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS badge VARCHAR(255);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS rating VARCHAR(50);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS oldprice DECIMAL(10,2);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS newprice DECIMAL(10,2);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS discount DECIMAL(5,2);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS qrurl VARCHAR(255);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS qrtitle VARCHAR(255);\nALTER TABLE courses ADD COLUMN IF NOT EXISTS qrdesc TEXT;\n\n\n-- Added for Course Subjects\nALTER TABLE course_subjects ADD COLUMN IF NOT EXISTS courseid VARCHAR(255);\nALTER TABLE course_subjects ADD COLUMN IF NOT EXISTS thumbnail VARCHAR(255);\nALTER TABLE course_subjects ADD COLUMN IF NOT EXISTS description TEXT;\nALTER TABLE course_subjects ADD COLUMN IF NOT EXISTS telegramlink VARCHAR(255);\n\n\n-- Added for Course Modules and Lectures\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS subjectid VARCHAR(255);\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS modulename VARCHAR(255);\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS title VARCHAR(255);\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS description TEXT;\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS displayorder INTEGER DEFAULT 0;\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS createdat TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;\nALTER TABLE course_modules ADD COLUMN IF NOT EXISTS updatedat TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;\n\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS moduleid VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS title VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS thumbnail VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS videourl VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS ytlink VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS videotype VARCHAR(50);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS videoid VARCHAR(255);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS duration VARCHAR(50);\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS description TEXT;\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS displayorder INTEGER DEFAULT 0;\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS createdat TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;\nALTER TABLE course_lectures ADD COLUMN IF NOT EXISTS updatedat TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;\n
-- Added for Course Announcements
CREATE TABLE IF NOT EXISTS course_announcements (
    id VARCHAR(255) PRIMARY KEY,
    subjectId VARCHAR(255),
    title VARCHAR(255),
    message TEXT,
    imageUrl VARCHAR(255),
    startDate TIMESTAMPTZ,
    endDate TIMESTAMPTZ,
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE course_announcements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ""Allow all on course_announcements"" ON course_announcements;
CREATE POLICY ""Allow all on course_announcements"" ON course_announcements FOR ALL USING (true) WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE course_announcements;

-- Added for Live Sessions
CREATE TABLE IF NOT EXISTS live_sessions (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    instructorName VARCHAR(255),
    description TEXT,
    youtubeUrl VARCHAR(255),
    youtubeVideoId VARCHAR(255),
    thumbnail VARCHAR(255),
    year VARCHAR(50),
    semester VARCHAR(50),
    subject VARCHAR(255),
    subjectId VARCHAR(255),
    startDate VARCHAR(50),
    startTime VARCHAR(50),
    duration VARCHAR(50),
    isActive BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'Upcoming',
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMPTZ
);

ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on live_sessions" ON live_sessions;
CREATE POLICY "Allow all on live_sessions" ON live_sessions FOR ALL USING (true) WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE live_sessions;

-- Added for Booster Courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS type VARCHAR(50) DEFAULT 'normal';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS wallpaper VARCHAR(255);

-- WhatsApp Groups
CREATE TABLE IF NOT EXISTS whatsapp_groups (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    link VARCHAR(255) NOT NULL,
    displayOrder INTEGER DEFAULT 0,
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE whatsapp_groups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on whatsapp_groups" ON whatsapp_groups;
CREATE POLICY "Allow all on whatsapp_groups" ON whatsapp_groups FOR ALL USING (true) WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE whatsapp_groups;

-- Added for CA Papers (CA1, CA2, CA3, CA4)
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "caType" VARCHAR(50) DEFAULT 'CA1';
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS catype VARCHAR(50) DEFAULT 'CA1';
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "collegeName" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "teacherName" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS stream VARCHAR(100);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "yearSem" VARCHAR(50);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "paperTitle" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "driveLink" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "uploadedBy" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "uploaderId" VARCHAR(255);
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "uploadType" VARCHAR(50) DEFAULT 'User';
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS approved BOOLEAN DEFAULT false;
ALTER TABLE ca3_papers ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ;

