-- ===========================
-- Таблица: programs
-- ===========================
CREATE TABLE IF NOT EXISTS programs (
                                        id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                        name VARCHAR(255) NOT NULL,
                                        price NUMERIC(10, 2) NOT NULL,
                                        program_type VARCHAR(100) NOT NULL,
                                        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ===========================
-- Таблица: modules
-- ===========================
CREATE TABLE IF NOT EXISTS modules (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       name VARCHAR(255) NOT NULL,
                                       description TEXT NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       deleted_at TIMESTAMP
);


-- ===========================
-- Таблица: courses
-- ===========================
CREATE TABLE IF NOT EXISTS courses (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       name VARCHAR(255) NOT NULL,
                                       description TEXT NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       deleted_at TIMESTAMP
);


-- ===========================
-- Таблица: lessons
-- ===========================
CREATE TABLE IF NOT EXISTS lessons (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       name VARCHAR(255) NOT NULL,
                                       content TEXT NOT NULL,
                                       video_url TEXT,
                                       position INTEGER,            -- убрали NOT NULL
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       deleted_at TIMESTAMP,
                                       course_id BIGINT,            -- убрали NOT NULL
                                       CONSTRAINT fk_lessons_courses
                                           FOREIGN KEY (course_id) REFERENCES courses(id)
);


-- ===========================
-- Таблица связи: program_modules
-- связь многие-к-многим Programs <-> Modules
-- ===========================
CREATE TABLE IF NOT EXISTS program_modules (
                                               program_id BIGINT NOT NULL,
                                               module_id BIGINT NOT NULL,
                                               PRIMARY KEY (program_id, module_id),
                                               CONSTRAINT fk_pm_programs
                                                   FOREIGN KEY (program_id) REFERENCES programs(id),
                                               CONSTRAINT fk_pm_modules
                                                   FOREIGN KEY (module_id) REFERENCES modules(id)
);


-- ===========================
-- Таблица связи: module_courses
-- связь многие-к-многим Modules <-> Courses
-- ===========================
CREATE TABLE IF NOT EXISTS course_modules (
                                              course_id BIGINT NOT NULL,
                                              module_id BIGINT NOT NULL,
                                              PRIMARY KEY (course_id, module_id),
                                              CONSTRAINT fk_cm_courses
                                                  FOREIGN KEY (course_id) REFERENCES courses(id),
                                              CONSTRAINT fk_cm_modules
                                                  FOREIGN KEY (module_id) REFERENCES modules(id)
);

-- ===========================
-- Таблица: teaching_groups
-- ===========================
CREATE TABLE IF NOT EXISTS teaching_groups (
                                               id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                               slug VARCHAR(255) NOT NULL UNIQUE,
                                               created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                               updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ===========================
-- Таблица: users
-- ===========================
CREATE TABLE IF NOT EXISTS users (
                                     id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                     name VARCHAR(255) NOT NULL,
                                     email VARCHAR(255) NOT NULL UNIQUE,
                                     password_hash TEXT,              -- убрали NOT NULL
                                     role VARCHAR(50) NOT NULL,       -- student | teacher | admin
                                     teaching_group_id BIGINT,        -- убрали NOT NULL
                                     created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                     updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                     deleted_at TIMESTAMP,
                                     CONSTRAINT fk_users_groups
                                         FOREIGN KEY (teaching_group_id) REFERENCES teaching_groups(id)
);

-- ===========================
-- Таблица: enrollments
-- Подписки пользователя на программу
-- ===========================
CREATE TABLE IF NOT EXISTS enrollments (
                                           id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                           user_id BIGINT NOT NULL,
                                           program_id BIGINT NOT NULL,
                                           status VARCHAR(50) NOT NULL CHECK (status IN ('active', 'pending', 'cancelled', 'completed')),
                                           created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                           updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                           CONSTRAINT fk_enrollments_user
                                               FOREIGN KEY (user_id) REFERENCES users(id),

                                           CONSTRAINT fk_enrollments_program
                                               FOREIGN KEY (program_id) REFERENCES programs(id)
);



-- ===========================
-- Таблица: payments
-- Оплаты за подписки
-- ===========================
CREATE TABLE IF NOT EXISTS payments (
                                        id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                        enrollment_id BIGINT NOT NULL,
                                        amount NUMERIC(10,2) NOT NULL,
                                        status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
                                        paid_at TIMESTAMP,
                                        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                        updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                        CONSTRAINT fk_payments_enrollment
                                            FOREIGN KEY (enrollment_id) REFERENCES enrollments(id)
);



-- ===========================
-- Таблица: program_completions
-- Прогресс пользователя по программе
-- ===========================
CREATE TABLE IF NOT EXISTS program_completions (
                                                   id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                                   user_id BIGINT NOT NULL,
                                                   program_id BIGINT NOT NULL,
                                                   status VARCHAR(50) NOT NULL CHECK (status IN ('active', 'completed', 'pending', 'cancelled')),
                                                   started_at TIMESTAMP,
                                                   completed_at TIMESTAMP,
                                                   created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                                   updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                                   CONSTRAINT fk_program_completion_user
                                                       FOREIGN KEY (user_id) REFERENCES users(id),
                                                   CONSTRAINT fk_program_completion_program
                                                       FOREIGN KEY (program_id) REFERENCES programs(id)
);


-- ===========================
-- Таблица: certificates
-- Сертификаты, которые получает студент
-- ===========================
CREATE TABLE IF NOT EXISTS certificates (
                                            id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                            user_id BIGINT NOT NULL,
                                            program_id BIGINT NOT NULL,
                                            url TEXT NOT NULL,
                                            issued_at TIMESTAMP NOT NULL,
                                            created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                            updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                            CONSTRAINT fk_certificates_user
                                                FOREIGN KEY (user_id) REFERENCES users(id),
                                            CONSTRAINT fk_certificates_program
                                                FOREIGN KEY (program_id) REFERENCES programs(id)
);


-- ===========================
-- Таблица: quizzes
-- Тесты, привязанные к урокам
-- ===========================
-- ===========================
-- Таблица: quizzes
-- Тесты, привязанные к урокам
-- ===========================
CREATE TABLE IF NOT EXISTS quizzes (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       lesson_id BIGINT NOT NULL,
                                       name VARCHAR(255) NOT NULL,
                                       content JSONB NOT NULL,          -- было TEXT, стало JSONB
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       CONSTRAINT fk_quizzes_lesson
                                           FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);


-- ===========================
-- Таблица: exercises
-- Практические задания после уроков
-- ===========================
CREATE TABLE IF NOT EXISTS exercises (
                                         id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                         lesson_id BIGINT NOT NULL,
                                         name VARCHAR(255) NOT NULL,
                                         url TEXT NOT NULL,
                                         created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                         updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                         CONSTRAINT fk_exercises_lesson
                                             FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);


-- ===========================
-- Таблица: discussions
-- Древовидные обсуждения под уроками
-- ===========================
CREATE TABLE IF NOT EXISTS discussions (
                                           id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                           lesson_id BIGINT NOT NULL,
                                           user_id BIGINT NOT NULL,
                                           text JSONB NOT NULL,          -- было TEXT NOT NULL, стало JSONB NOT NULL
                                           created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                           updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                           CONSTRAINT fk_discussions_lesson
                                               FOREIGN KEY (lesson_id) REFERENCES lessons(id),
                                           CONSTRAINT fk_discussions_user
                                               FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ===========================
-- Таблица: blog
-- Личные статьи пользователей
-- ===========================
CREATE TABLE IF NOT EXISTS blogs (
                                     id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                     user_id BIGINT NOT NULL,
                                     name VARCHAR(255) NOT NULL,
                                     content TEXT NOT NULL,
                                     status VARCHAR(50) NOT NULL CHECK (status IN ('created', 'in moderation', 'published', 'archived')),
                                     created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                     updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                     CONSTRAINT fk_blogs_user
                                         FOREIGN KEY (user_id) REFERENCES users(id)
);


