-- ============================================
-- БАЗА ДАННЫХ ONLEARN - PostgreSQL 13+
-- Физическая модель на основе диаграмм из Лабы 3
-- ============================================

-- Создание базы данных
CREATE DATABASE onlearn_db;
\c onlearn_db;

-- Расширение для UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. ТАБЛИЦА ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'student' 
        CHECK (role IN ('student', 'teacher', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. ТАБЛИЦА ПРОФИЛЕЙ
-- ============================================
CREATE TABLE profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    avatar_url VARCHAR(500),
    bio TEXT,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. ТАБЛИЦА КУРСОВ
-- ============================================
CREATE TABLE courses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    level VARCHAR(20) DEFAULT 'beginner' 
        CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    teacher_id UUID NOT NULL REFERENCES users(id),
    duration_hours INTEGER,
    rating DECIMAL(3,2) DEFAULT 0.00,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 4. ТАБЛИЦА УРОКОВ
-- ============================================
CREATE TABLE lessons (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    content_url VARCHAR(500),
    duration_minutes INTEGER,
    order_index INTEGER NOT NULL,
    type VARCHAR(20) DEFAULT 'video' 
        CHECK (type IN ('video', 'text', 'presentation', 'interactive')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 5. ТАБЛИЦА МАТЕРИАЛОВ
-- ============================================
CREATE TABLE materials (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(200),
    type VARCHAR(20) NOT NULL 
        CHECK (type IN ('pdf', 'video', 'image', 'code', 'presentation', 'archive')),
    file_url VARCHAR(500) NOT NULL,
    file_size BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 6. ТАБЛИЦА ТЕСТОВ
-- ============================================
CREATE TABLE tests (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    lesson_id UUID UNIQUE NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    passing_score INTEGER DEFAULT 70,
    attempt_limit INTEGER DEFAULT 3,
    time_limit_minutes INTEGER,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 7. ТАБЛИЦА ЗАПИСЕЙ НА КУРСЫ
-- ============================================
CREATE TABLE enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active' 
        CHECK (status IN ('active', 'completed', 'dropped', 'pending')),
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    UNIQUE(user_id, course_id)
);

-- ============================================
-- 8. ТАБЛИЦА ПРОГРЕССА
-- ============================================
CREATE TABLE progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    enrollment_id UUID UNIQUE NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    completed_lessons INTEGER DEFAULT 0,
    completed_tests INTEGER DEFAULT 0,
    total_lessons INTEGER,
    total_tests INTEGER,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. ТАБЛИЦА СЕРТИФИКАТОВ
-- ============================================
CREATE TABLE certificates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    enrollment_id UUID UNIQUE NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    course_id UUID NOT NULL REFERENCES courses(id),
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    certificate_url VARCHAR(500),
    verification_code VARCHAR(100) UNIQUE
);

-- ============================================
-- 10. ТАБЛИЦА ТЕМ ФОРУМА
-- ============================================
CREATE TABLE forum_threads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 11. ТАБЛИЦА КОММЕНТАРИЕВ
-- ============================================
CREATE TABLE comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    thread_id UUID NOT NULL REFERENCES forum_threads(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 12. ТАБЛИЦА ПОПЫТОК ТЕСТОВ
-- ============================================
CREATE TABLE test_attempts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    test_id UUID NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    score INTEGER,
    max_score INTEGER,
    is_passed BOOLEAN,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    attempt_number INTEGER NOT NULL,
    answers_data JSONB,
    UNIQUE(test_id, user_id, attempt_number)
);

-- ============================================
-- СОЗДАНИЕ ИНДЕКСОВ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_courses_teacher_id ON courses(teacher_id);
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE INDEX idx_lessons_order_index ON lessons(order_index);
CREATE INDEX idx_materials_lesson_id ON materials(lesson_id);
CREATE INDEX idx_enrollments_user_id ON enrollments(user_id);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);
CREATE INDEX idx_progress_enrollment_id ON progress(enrollment_id);
CREATE INDEX idx_certificates_enrollment_id ON certificates(enrollment_id);
CREATE INDEX idx_certificates_verification_code ON certificates(verification_code);
CREATE INDEX idx_forum_threads_course_id ON forum_threads(course_id);
CREATE INDEX idx_forum_threads_user_id ON forum_threads(user_id);
CREATE INDEX idx_comments_thread_id ON comments(thread_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_test_attempts_test_id ON test_attempts(test_id);
CREATE INDEX idx_test_attempts_user_id ON test_attempts(user_id);

-- ============================================
-- КОММЕНТАРИИ К ТАБЛИЦАМ (ДЛЯ ДОКУМЕНТАЦИИ)
-- ============================================
COMMENT ON TABLE users IS 'Основная таблица пользователей системы. Содержит данные для аутентификации и авторизации.';
COMMENT ON TABLE profiles IS 'Дополнительная информация о пользователях. Один к одному с users.';
COMMENT ON TABLE courses IS 'Таблица курсов платформы. Создаются преподавателями (teacher_id).';
COMMENT ON TABLE lessons IS 'Уроки, входящие в состав курсов. Упорядочены по order_index.';
COMMENT ON TABLE materials IS 'Дополнительные материалы к урокам (файлы, презентации, код).';
COMMENT ON TABLE tests IS 'Тесты, привязанные к урокам. Один тест на урок.';
COMMENT ON TABLE enrollments IS 'Записи студентов на курсы. Отслеживает статус прохождения.';
COMMENT ON TABLE progress IS 'Прогресс студента по конкретному курсу. Рассчитывается автоматически.';
COMMENT ON TABLE certificates IS 'Выданные сертификаты об окончании курсов. Имеют уникальный verification_code.';
COMMENT ON TABLE forum_threads IS 'Темы для обсуждения на форуме курса. Могут быть привязаны к уроку.';
COMMENT ON TABLE comments IS 'Комментарии в темах форума. Поддерживают вложенность через parent_comment_id.';
COMMENT ON TABLE test_attempts IS 'История попыток прохождения тестов. Хранит результаты и ответы.';
