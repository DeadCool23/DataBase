CREATE EXTENSION IF NOT EXISTS plpython3u;

-- Определяемая  пользователем скалярная функция
CREATE OR REPLACE FUNCTION calc_factorial(n INTEGER)
RETURNS BIGINT
AS $$
    if n < 0:
        raise ValueError("n must be a non-negative integer")
    elif n == 0:
        return 1
    else:
        result = 1
        for i in range(1, n + 1):
            result *= i
        return result
$$ LANGUAGE plpython3u;

-- Тест
SELECT calc_factorial(5);


-- Пользовательская агрегатная функция
CREATE OR REPLACE FUNCTION total_costs_step(state DOUBLE PRECISION, cost DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
AS $$
    return state + (cost if cost is not None else 0.0)
$$ LANGUAGE plpython3u;


CREATE OR REPLACE AGGREGATE total_repair_costs(DOUBLE PRECISION) (
    SFUNC = total_costs_step,
    STYPE = DOUBLE PRECISION,
    INITCOND = '0'
);

-- Тест
SELECT worker_id, total_repair_costs(costs) AS total_costs
FROM repairs
GROUP BY worker_id;

-- Пользовательская табличная функция
CREATE OR REPLACE FUNCTION get_user_repairs(user_id INT)
RETURNS TABLE (
    car_id INT,
    car_brand VARCHAR,
    car_model VARCHAR,
    repair_type VARCHAR,
    repair_cost DOUBLE PRECISION,
    repair_date DATE
)
AS $$
    result = plpy.execute(f"""
        SELECT c.id AS car_id,
               c.brand AS car_brand,
               c.model AS car_model,
               r.repair_type,
               r.costs AS repair_cost,
               r.repair_date
        FROM cars c
        JOIN requests req ON req.car_id = c.id
        JOIN repairs r ON r.request_id = req.id
        WHERE c.user_id = {user_id}
    """)
    return result
$$ LANGUAGE plpython3u;

-- Тест
SELECT * FROM get_user_repairs(5);

-- Хранимая процедура
CREATE OR REPLACE PROCEDURE find_most_common_repair_type(user_id INT)
AS $$
result = plpy.execute(f"""
    SELECT r.repair_type, COUNT(r.repair_type) AS repair_count
    FROM cars c
    JOIN requests req ON req.car_id = c.id
    JOIN repairs r ON r.request_id = req.id
    WHERE c.user_id = {user_id}
    GROUP BY r.repair_type
    ORDER BY repair_count DESC
    LIMIT 1
""")

if len(result) == 0:
    plpy.notice(f"No repairs found for user {user_id}.")
else:
    most_common_repair = result[0]['repair_type']
    count = result[0]['repair_count']
    plpy.notice(f"The most common repair type for user {user_id} is: '{most_common_repair}' with {count} occurrences.")
$$ LANGUAGE plpython3u;

-- Тест
CALL find_most_common_repair_type(52);


-- Триггер
CREATE OR REPLACE FUNCTION log_request_status_change()
RETURNS TRIGGER
AS $$
if TD['old']['request_status'] != TD['new']['request_status']:
    plpy.notice(f"Request ID: {TD['new']['id']}, Status changed from '{TD['old']['request_status']}' to '{TD['new']['request_status']}'")
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER trigger_log_request_status_change
BEFORE UPDATE ON requests
FOR EACH ROW
WHEN (OLD.request_status IS DISTINCT FROM NEW.request_status)
EXECUTE FUNCTION log_request_status_change();

-- Тест
SELECT * from requests WHERE id = 52;

UPDATE requests
SET request_status = 'Ремонтируется'
WHERE id = 52;

-- Определяемый тип данных

CREATE TYPE worker_car_repair_info AS
(
    worker_name VARCHAR,
    car_brand VARCHAR,
    car_model VARCHAR,
    request_date DATE,
    repair_cost DOUBLE PRECISION
);

CREATE OR REPLACE FUNCTION get_expensive_repairs_py(min_cost DOUBLE PRECISION)
RETURNS SETOF worker_car_repair_info
AS $$
    query = '''
        SELECT 
            w.first_name || ' ' || w.last_name AS worker_name,
            c.brand AS car_brand,
            c.model AS car_model,
            r.request_date AS request_date,
            rep.costs AS repair_cost
        FROM 
            repairs AS rep
            JOIN workers AS w ON rep.worker_id = w.id
            JOIN requests AS r ON rep.request_id = r.id
            JOIN cars AS c ON r.car_id = c.id
        WHERE
            rep.costs > %s
    ''' % (min_cost)

    result = plpy.execute(query)
    
    return result
$$ LANGUAGE plpython3u;

-- Тест
SELECT * FROM get_expensive_repairs_py(1000);
