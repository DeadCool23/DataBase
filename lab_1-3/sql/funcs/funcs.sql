-- Скалярная функция ===========================================================
CREATE OR REPLACE FUNCTION get_user_full_name(user_id INT)
RETURNS VARCHAR(101)
AS $$
DECLARE
    user_first_name VARCHAR(50);
    user_last_name VARCHAR(50);
BEGIN
    SELECT first_name, last_name INTO user_first_name, user_last_name
    FROM users
    WHERE id = get_user_full_name.user_id;
    RETURN user_first_name || ' ' || user_last_name;
END;
$$ LANGUAGE plpgsql;

-- Тест
SELECT get_user_full_name(1); 

-- Подставляемая табличная функция ===========================================
CREATE OR REPLACE FUNCTION get_repair_details(request_id INT)
RETURNS TABLE (
    repair_id INT,
    worker_name VARCHAR(101),
    repair_status VARCHAR(50),
    repair_type VARCHAR(50),
    costs DOUBLE PRECISION,
    repair_date DATE
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id AS repair_id,
        get_user_full_name(w.id) AS worker_name,
        r.repair_status,
        r.repair_type,
        r.costs,
        r.repair_date
    FROM repairs r
    JOIN workers w ON r.worker_id = w.id
    WHERE r.request_id = get_repair_details.request_id;
END;
$$ LANGUAGE plpgsql;

-- Тест
SELECT * from get_repair_details(30);


-- Многооператорная табличная функция ============================================
CREATE OR REPLACE FUNCTION get_user_car_repair_details(user_id INT)
RETURNS TABLE (
    car_id INT,
    brand VARCHAR(50),
    model VARCHAR(50),
    release_year INT,
    request_id INT,
    request_status VARCHAR(50),
    request_date DATE,
    repair_id INT,
    worker_name VARCHAR(101),
    repair_status VARCHAR(50),
    repair_type VARCHAR(50),
    costs DOUBLE PRECISION,
    repair_date DATE
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS car_id,
        c.brand,
        c.model,
        c.release_year,
        r.id AS request_id,
        r.request_status,
        r.request_date,
        re.id AS repair_id,
        get_user_full_name(w.id) AS worker_name,
        re.repair_status,
        re.repair_type,
        re.costs,
        re.repair_date
    FROM cars c
    LEFT JOIN requests r ON c.id = r.car_id
    LEFT JOIN repairs re ON r.id = re.request_id
    LEFT JOIN workers w ON re.worker_id = w.id
    WHERE c.user_id = get_user_car_repair_details.user_id;
END;
$$ LANGUAGE plpgsql;

-- Тест
SELECT * from get_user_car_repair_details(21);

-- Рекурсивная функция =========================================================================
CREATE OR REPLACE FUNCTION fibonacci_func(n INT) 
RETURNS INT AS $$
BEGIN
    IF n = 0 THEN
        RETURN 0;
    ELSIF n = 1 THEN
        RETURN 1;
    ELSE
        RETURN fibonacci_func(n - 1) + fibonacci_func(n - 2);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Тест
SELECT * from fibonacci_func(4);