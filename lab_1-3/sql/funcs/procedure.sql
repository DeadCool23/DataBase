-- Хранимая процедура с параметрами ===============================================
CREATE OR REPLACE PROCEDURE update_repair_status(
    p_repair_id INT,
    p_new_status VARCHAR(50)
)
AS $$
BEGIN
    UPDATE repairs
    SET repair_status = p_new_status
    WHERE id = p_repair_id;
END;
$$ LANGUAGE plpgsql;

-- Тест
CALL update_repair_status(121, 'Ремонт окончен');

-- Рекурсивная хранимая процедура ============================================================
CREATE OR REPLACE PROCEDURE fibonacci_proc(IN n INT, OUT result INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF n = 0 THEN
        result := 0;
    ELSIF n = 1 THEN
        result := 1;
    ELSE
        DECLARE
            temp1 INT;
            temp2 INT;
        BEGIN
            CALL fibonacci_proc(n - 1, temp1);
            CALL fibonacci_proc(n - 2, temp2);
            result := temp1 + temp2;
        END;
    END IF;
END;
$$;

-- Тест
DO $$
DECLARE
    result INT;
BEGIN
    CALL fibonacci_proc(5, result);
    RAISE NOTICE 'Fibonacci number: %', result;
END $$;


-- Хранимая процедура с курсором =======================================================
CREATE OR REPLACE PROCEDURE increment_work_experience()
AS $$
DECLARE
    worker_rec RECORD;
    worker_cursor CURSOR FOR SELECT id, work_experience FROM workers;
BEGIN
    OPEN worker_cursor;
    
    LOOP
        FETCH worker_cursor INTO worker_rec;
        EXIT WHEN NOT FOUND;

        UPDATE workers SET work_experience = work_experience + 1 WHERE id = worker_rec.id;
    END LOOP;

    CLOSE worker_cursor;
END;
$$ LANGUAGE plpgsql;

-- Тест
CALL increment_work_experience();

-- Хранимая процедура доступа к метаданным =================================================
CREATE OR REPLACE PROCEDURE get_metadata()
AS $$
DECLARE
    row RECORD;
BEGIN
    FOR row IN 
        SELECT table_name, column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name IN ('users', 'cars', 'workers', 'requests', 'repairs')
    LOOP
        RAISE NOTICE 'Table: %, Column: %, Data Type: %', row.table_name, row.column_name, row.data_type;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Тест
CALL get_metadata();