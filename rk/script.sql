CREATE DATABASE rk;

\c rk;

-- Создание

CREATE TABLE candy_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ingredients TEXT,
    type_desc TEXT
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    INN VARCHAR(12) NOT NULL,
    address TEXT
);

CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    reg_date DATE,
    rating INTEGER
);

CREATE TABLE supplier_store (
    supplier_id INT REFERENCES suppliers(id) ON DELETE CASCADE,
    store_id INT REFERENCES stores(id) ON DELETE CASCADE,
    PRIMARY KEY (supplier_id, store_id)
);

CREATE TABLE candy_store (
    candy_id INT REFERENCES candy_types(id) ON DELETE CASCADE,
    store_id INT REFERENCES stores(id) ON DELETE CASCADE,
    PRIMARY KEY (candy_id, store_id)
);

CREATE TABLE candy_supplier (
    candy_id INT REFERENCES candy_types(id) ON DELETE CASCADE,
    supplier_id INT REFERENCES suppliers(ID) ON DELETE CASCADE,
    PRIMARY KEY (candy_id, Supplier_ID)
);

-- Ограничения

ALTER TABLE candy_types
    ADD CONSTRAINT check_id CHECK (id > 0),
    ADD CONSTRAINT unique_candy_name UNIQUE (name),
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN ingredients SET NOT NULL;

ALTER TABLE suppliers
    ADD CONSTRAINT check_id CHECK (id > 0),
    ADD CONSTRAINT unique_supplier_name UNIQUE (name),
    ADD CONSTRAINT unique_inn UNIQUE (INN),
    ADD CONSTRAINT check_inn CHECK (LENGTH(INN) = 12),
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN address SET NOT NULL;

ALTER TABLE stores
    ADD CONSTRAINT check_id CHECK (id > 0),
    ADD CONSTRAINT unique_store_name UNIQUE (name),
    ADD CONSTRAINT check_rating CHECK (rating BETWEEN 1 AND 5),
    ADD CONSTRAINT check_reg_date CHECK (reg_date IS NOT NULL),
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN address SET NOT NULL;

-- Заполнение

INSERT INTO candy_types (name, ingredients, type_desc) VALUES
('Конфета1', 'Сахар, Какао', 'Шоколадная конфета'),
('Конфета2', 'Молоко, Сахар', 'Карамельная конфета'),
('Конфета3', 'Орехи, Мёд', 'Ореховая конфета'),
('Конфета4', 'Какао, Молоко', 'Молочный шоколад'),
('Конфета5', 'Фрукты, Сахар', 'Фруктовая конфета'),
('Конфета6', 'Арахис, Шоколад', 'Арахисовая конфета'),
('Конфета7', 'Карамель, Молоко', 'Жевательная карамель'),
('Конфета8', 'Мята, Сахар', 'Мятная конфета'),
('Конфета9', 'Зефир, Шоколад', 'Зефир в шоколаде'),
('Конфета10', 'Миндаль, Какао', 'Миндальная конфета');

INSERT INTO suppliers (name, INN, address) VALUES
('Поставщик1', '123456789078', 'Улица Ленина, 1, Город А'),
('Поставщик2', '098765432152', 'Улица Пушкина, 5, Город Б'),
('Поставщик3', '234567890123', 'Улица Горького, 10, Город В'),
('Поставщик4', '345678901290', 'Улица Чехова, 15, Город Г'),
('Поставщик5', '456789012351', 'Улица Толстого, 20, Город Д'),
('Поставщик6', '567890123462', 'Улица Тургенева, 25, Город Е'),
('Поставщик7', '678901234578', 'Улица Некрасова, 30, Город Ж'),
('Поставщик8', '789012345699', 'Улица Гоголя, 35, Город З'),
('Поставщик9', '890123456787', 'Улица Лермонтова, 40, Город И'),
('Поставщик10', '901234567824', 'Улица Достоевского, 45, Город К');

INSERT INTO stores (name, address, reg_date, rating) VALUES
('Магазин1', 'Проспект Мира, 10, Город А', '2023-01-01', 5),
('Магазин2', 'Улица Свободы, 15, Город Б', '2023-02-01', 4),
('Магазин3', 'Улица Труда, 20, Город В', '2023-03-01', 3),
('Магазин4', 'Проспект Ленина, 25, Город Г', '2023-04-01', 4),
('Магазин5', 'Улица Победы, 30, Город Д', '2023-05-01', 5),
('Магазин6', 'Проспект Гагарина, 35, Город Е', '2023-06-01', 2),
('Магазин7', 'Улица Красная, 40, Город Ж', '2023-07-01', 3),
('Магазин8', 'Проспект Октября, 45, Город З', '2023-08-01', 4),
('Магазин9', 'Улица Советская, 50, Город И', '2023-09-01', 5),
('Магазин10', 'Проспект Победы, 55, Город К', '2023-10-01', 3);

INSERT INTO supplier_store (supplier_id, store_id) VALUES
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5), (3, 6),
(4, 7), (4, 8),
(5, 9), (5, 10);

INSERT INTO candy_store (candy_id, store_id) VALUES
(1, 1), (2, 1),
(3, 2), (4, 2),
(5, 3), (6, 3),
(7, 4), (8, 4),
(9, 5), (10, 5);

INSERT INTO candy_supplier (candy_id, supplier_id) VALUES
(1, 1), (2, 1), 
(3, 1), (2, 2),
(3, 3), (4, 4),
(5, 5), (6, 6),
(7, 7), (8, 8),
(9, 9), (10, 10);

-- SELECT-запросы

-- 1.
SELECT * FROM stores
WHERE rating > 3;

-- 2.
SELECT ROW_NUMBER() OVER (ORDER BY rating DESC) AS row_num, 
    name, address, rating
FROM stores;

-- 3.
SELECT s.name AS supplier_name,
    (SELECT COUNT(*)
    FROM candy_supplier cs
    WHERE cs.supplier_id = s.id) AS candy_count
FROM suppliers s;

-- Хранимая процедура

CREATE OR REPLACE PROCEDURE find_sql_objects(search_text TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    object_name TEXT;
    object_definition TEXT;
BEGIN
    FOR object_name, object_definition IN
        SELECT proname AS object_name,
               CASE
                   WHEN prokind = 'f' THEN pg_get_functiondef(pg_proc.oid)
                   WHEN prokind = 'p' THEN pg_get_functiondef(pg_proc.oid)
                   ELSE NULL
               END AS object_definition
        FROM pg_proc
        JOIN pg_namespace ON pg_namespace.oid = pg_proc.pronamespace
        WHERE pg_get_functiondef(pg_proc.oid) ILIKE '%' || search_text || '%'
          AND pg_namespace.nspname NOT IN ('pg_catalog', 'information_schema')
          AND prokind IN ('f', 'p')
    LOOP
        RAISE NOTICE 'Object Name: %, Definition: %', object_name, object_definition;
    END LOOP;
END;
$$;

-- Тесты

CALL find_sql_objects('SELECT');
CALL find_sql_objects('FROM');
CALL find_sql_objects('WHERE');
CALL find_sql_objects('UNDEFINEDWORD');
