-- ===========================
-- Таблица: programs
-- ===========================
CREATE TABLE IF NOT EXISTS programs (
                                        id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                        title VARCHAR(255) NOT NULL,
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
                                       title VARCHAR(255) NOT NULL,
                                       description TEXT NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);


-- ===========================
-- Таблица: courses
-- ===========================
CREATE TABLE IF NOT EXISTS courses (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       title VARCHAR(255) NOT NULL,
                                       description TEXT NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);


-- ===========================
-- Таблица: lessons
-- ===========================
CREATE TABLE IF NOT EXISTS lessons (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       title VARCHAR(255) NOT NULL,
                                       content TEXT NOT NULL,
                                       video_url TEXT,
                                       position INTEGER NOT NULL,
                                       created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                       is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
                                       course_id BIGINT NOT NULL,
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
CREATE TABLE IF NOT EXISTS module_courses (
                                              module_id BIGINT NOT NULL,
                                              course_id BIGINT NOT NULL,
                                              PRIMARY KEY (module_id, course_id),
                                              CONSTRAINT fk_mc_modules
                                                  FOREIGN KEY (module_id) REFERENCES modules(id),
                                              CONSTRAINT fk_mc_courses
                                                  FOREIGN KEY (course_id) REFERENCES courses(id)
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
                                     username VARCHAR(255) NOT NULL UNIQUE,
                                     email VARCHAR(255) NOT NULL UNIQUE,
                                     password_hash TEXT NOT NULL,
                                     role VARCHAR(50) NOT NULL,             -- student | teacher | admin
                                     teaching_group_id BIGINT NOT NULL,
                                     created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                     updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

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
                                           status VARCHAR(50) NOT NULL,      -- active | pending | cancelled | completed
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
                                        status VARCHAR(50) NOT NULL,      -- pending | paid | failed | refunded
                                        paid_at TIMESTAMP,                -- дата оплаты (может быть NULL до оплаты)
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
                                                   status VARCHAR(50) NOT NULL,      -- active | completed | pending | cancelled
                                                   started_at TIMESTAMP,
                                                   finished_at TIMESTAMP,
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
                                            certificate_url TEXT NOT NULL,
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
CREATE TABLE IF NOT EXISTS quizzes (
                                       id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       lesson_id BIGINT NOT NULL,
                                       title VARCHAR(255) NOT NULL,
                                       content TEXT NOT NULL,
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
                                         title VARCHAR(255) NOT NULL,
                                         exercise_url TEXT NOT NULL,
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
                                           parent_id BIGINT,                           -- ссылка на родительское сообщение (NULL — корень ветки)
                                           content TEXT NOT NULL,
                                           created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                           updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                           CONSTRAINT fk_discussions_lesson
                                               FOREIGN KEY (lesson_id) REFERENCES lessons(id),

                                           CONSTRAINT fk_discussions_user
                                               FOREIGN KEY (user_id) REFERENCES users(id),

                                           CONSTRAINT fk_discussions_parent
                                               FOREIGN KEY (parent_id) REFERENCES discussions(id)
);


-- ===========================
-- Таблица: blog
-- Личные статьи пользователей
-- ===========================
CREATE TABLE IF NOT EXISTS blog (
                                    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                    user_id BIGINT NOT NULL,
                                    title VARCHAR(255) NOT NULL,
                                    content TEXT NOT NULL,
                                    status VARCHAR(50) NOT NULL,                -- created | in moderation | published | archived
                                    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

                                    CONSTRAINT fk_blog_user
                                        FOREIGN KEY (user_id) REFERENCES users(id)
);

