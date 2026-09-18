-- ============================================
-- DDL АВТОТЕСТ: кестелер мен шектеулерді тексеру
-- ============================================

CREATE OR REPLACE FUNCTION assert(condition BOOLEAN, message TEXT)
RETURNS VOID AS $$
BEGIN
    IF NOT condition THEN
        RAISE EXCEPTION 'ТЕСТ СӘТСІЗ: %', message;
    END IF;

    RAISE NOTICE 'OK: %', message;
END;
$$ LANGUAGE plpgsql;


-- 1. Кестелердің бар-жоғын тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'departments'
    ),
    'departments кестесі жасалған'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'teachers'
    ),
    'teachers кестесі жасалған'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'students'
    ),
    'students кестесі жасалған'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'courses'
    ),
    'courses кестесі жасалған'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_name = 'enrollments'
    ),
    'enrollments кестесі жасалған'
);


-- 2. Маңызды бағандардың бар-жоғын тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'students'
        AND column_name = 'gpa'
    ),
    'students.gpa бағаны бар'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'students'
        AND column_name = 'department_id'
    ),
    'students.department_id бағаны бар'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'enrollments'
        AND column_name = 'grade'
    ),
    'enrollments.grade бағаны бар'
);


-- 3. PRIMARY KEY тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'departments'
        AND constraint_type = 'PRIMARY KEY'
    ),
    'departments PRIMARY KEY бар'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'students'
        AND constraint_type = 'PRIMARY KEY'
    ),
    'students PRIMARY KEY бар'
);


-- 4. FOREIGN KEY тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'students'
        AND constraint_type = 'FOREIGN KEY'
    ),
    'students кестесінде FOREIGN KEY бар'
);

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'enrollments'
        AND constraint_type = 'FOREIGN KEY'
    ),
    'enrollments кестесінде FOREIGN KEY бар'
);


-- 5. UNIQUE тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'teachers'
        AND constraint_type = 'UNIQUE'
    ),
    'teachers кестесінде UNIQUE шектеуі бар'
);


-- 6. CHECK шектеуін тексеру

SELECT assert(
    EXISTS (
        SELECT 1
        FROM information_schema.check_constraints cc
        JOIN information_schema.constraint_column_usage cu
        ON cc.constraint_name = cu.constraint_name
        WHERE cu.table_name = 'students'
        AND cu.column_name = 'gpa'
    ),
    'students.gpa бағанында CHECK шектеуі бар'
);


-- 7. Деректер енгізуді тексеру

INSERT INTO departments
(dept_name, dean_name, established_year, building)
VALUES
('Тест факультеті', 'Тест Декан', 2000, 'А корпусы');

SELECT assert(
    (
        SELECT COUNT(*)
        FROM departments
        WHERE dept_name = 'Тест факультеті'
    ) = 1,
    'departments кестесіне деректер енгізу жұмысы дұрыс'
);


-- 8. GPA CHECK шектеуінің жұмысын тексеру

DO $$
BEGIN

    BEGIN

        INSERT INTO students
        (
            first_name,
            last_name,
            birth_date,
            admission_year,
            gpa,
            department_id
        )
        SELECT
            'Тест',
            'Студент',
            '2000-01-01',
            2023,
            9.99,
            department_id
        FROM departments
        LIMIT 1;

        RAISE EXCEPTION
        'ТЕСТ СӘТСІЗ: GPA CHECK шектеуі жұмыс істемейді!';

    EXCEPTION
        WHEN check_violation THEN

            RAISE NOTICE
            'OK: GPA CHECK шектеуі дұрыс жұмыс істейді';

    END;

END;
$$;


RAISE NOTICE '============================';
RAISE NOTICE 'БАРЛЫҚ ТЕСТТЕР СӘТТІ ӨТТІ!';
RAISE NOTICE '============================';
