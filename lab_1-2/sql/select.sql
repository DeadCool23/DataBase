-- 1. Инструкция SELECT, использующая предикат сравнения.
-- выбирает все машины выпущенные после 2000
SELECT brand, model, release_year, vin, plate FROM cars
    WHERE release_year > 2000;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- выбирает все ремонты которые были созданы летом
SELECT repair_status,repair_type,costs,repair_date FROM repairs
    WHERE repair_date BETWEEN '2024-06-01' AND '2024-08-31';

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Находит все машины бренда BMW модельного ряда M
SELECT brand, model, release_year, vin, plate FROM cars
    WHERE brand = 'BMW' AND model LIKE 'M_';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Находит все заявки ремонтируемых мерседесов
SELECT * FROM requests r
    WHERE r.car_id IN (
        SELECT id FROM cars
            WHERE brand = 'Mercedes-Benz'
    ) AND request_status = 'Ремонтируется';

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Находит все машины полученные клиентами
SELECT * FROM cars c
    WHERE EXISTS (
        SELECT 1 FROM requests r
            WHERE r.car_id = c.id AND r.request_status = 'Получен клиентом'
    );

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- Выбирает машины моложе самой молодой лады
SELECT *
FROM cars car
WHERE car.release_year > ALL (
    SELECT c.release_year
    FROM cars c
    WHERE c.brand = 'Lada'
);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Выводит заработанные автосервисом деньги с каждого типа ремонта
SELECT rp.repair_type AS rtype, SUM(rp.costs) AS TotalCosts
FROM repairs rp
GROUP BY rp.repair_type

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Вычисляет мин макс и среднюю стоимость ремонта машин для тех которые были в ремонте
SELECT c.id AS car_id, c.brand, c.model, c.release_year,
       repair_stats.AvgRepairCost,
       repair_stats.MinRepairCost,
       repair_stats.MaxRepairCost
FROM cars c
JOIN (
    SELECT req.car_id,
           AVG(rp.costs) AS AvgRepairCost,
           MIN(rp.costs) AS MinRepairCost,
           MAX(rp.costs) AS MaxRepairCost
    FROM repairs rp
    JOIN requests req ON rp.request_id = req.id
    GROUP BY req.car_id
) AS repair_stats ON c.id = repair_stats.car_id
WHERE repair_stats.AvgRepairCost IS NOT NULL
  AND repair_stats.MinRepairCost IS NOT NULL
  AND repair_stats.MaxRepairCost IS NOT NULL;

-- 9. Инструкция SELECT, использующая простое выражение CASE.
-- Выводит как давно появилась машина
SELECT c.brand, c.model, c.release_year,
       CASE 
           WHEN c.release_year = EXTRACT(YEAR FROM CURRENT_DATE) THEN 'This Year'
           WHEN c.release_year = EXTRACT(YEAR FROM CURRENT_DATE) - 1 THEN 'Last Year'
           ELSE CAST(EXTRACT(YEAR FROM CURRENT_DATE) - c.release_year AS text) || ' years ago'
       END AS born
FROM cars c;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
-- Выводит категорию возраста автомобиля
SELECT c.id AS car_id, c.brand, c.model, c.release_year,
    CASE
        WHEN c.release_year = EXTRACT(YEAR FROM CURRENT_DATE) THEN 'New'
        WHEN c.release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 3 THEN 'Relatively New'
        WHEN c.release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10 THEN 'Old'
        ELSE 'Very Old'
    END AS AgeCategory
FROM cars c;

-- 11. Создание ново временно локально таблицы из результирующего набора данных инструкции SELECT.
-- Создание временной таблицы с кол-вом ремонтов автомобиля и стоимостью ремонтов
CREATE TEMP TABLE carsrepairs AS(
    SELECT c.id AS car_id, c.vin, c.plate, c.brand,
       COUNT(rp.id) AS RepairCount,
       SUM(rp.costs) AS TotalRepairCost
    FROM cars c
    JOIN requests req ON c.id = req.car_id
    JOIN repairs rp ON req.id = rp.request_id
    GROUP BY c.id
);
SELECT * FROM carsrepairs;

-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
-- Находит самую часто ремонтируюмую машину и самую дорого отремантированную машину
SELECT 'By Repair Count' AS Criteria, 
       c.brand || ' ' || c.model AS "Best Selling"
FROM cars c 
JOIN (
    SELECT req.car_id, COUNT(rp.id) AS RepairCount
    FROM repairs rp
    JOIN requests req ON rp.request_id = req.id
    GROUP BY req.car_id
    ORDER BY RepairCount DESC
    LIMIT 1
) AS BestRepair ON BestRepair.car_id = c.id
UNION
SELECT 'By Total Repair Cost' AS Criteria, 
       c.brand || ' ' || c.model AS "Best Selling"
FROM cars c
JOIN (
    SELECT req.car_id, SUM(rp.costs) AS TotalRepairCost
    FROM repairs rp
    JOIN requests req ON rp.request_id = req.id
    GROUP BY req.car_id
    ORDER BY TotalRepairCost DESC
    LIMIT 1
) AS BestCost ON BestCost.car_id = c.id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Выводит самую дорогую в обслуживании машину
SELECT 'By Total Repair Cost' AS Criteria, 
       c.brand || ' ' || c.model AS "Best Selling"
FROM cars c
WHERE c.id = (
    SELECT req.car_id
    FROM repairs rp
    JOIN requests req ON rp.request_id = req.id
    GROUP BY req.car_id
    HAVING SUM(rp.costs) = (
        SELECT MAX(TotalCost)
        FROM (
            SELECT SUM(rp.costs) AS TotalCost
            FROM repairs rp
            JOIN requests req ON rp.request_id = req.id
            GROUP BY req.car_id
        ) AS CostSummary
    )
);

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- выводид среднюю и минимальную стоимости ремостов брендов
SELECT
    c.brand,
    c.model,
    COALESCE(AVG(rp.costs), 0) AS AvgRepairCost,
    COALESCE(MIN(rp.costs), 0) AS MinRepairCost
FROM cars c 
LEFT JOIN requests rq ON c.id = rq.car_id
LEFT JOIN repairs rp ON rq.id = rp.request_id
GROUP BY c.brand, c.model;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Выводит все бренды у которых средняя стоимость ремонтов больше средней стоимости ремонтов всех автомобилей
SELECT 
    c.brand AS Brand,
    AVG(rp.costs) AS AvgRepairCost
FROM cars c 
JOIN requests rq ON c.id = rq.car_id
JOIN repairs rp ON rp.request_id = rq.id
GROUP BY c.brand
HAVING AVG(rp.costs) > (
    SELECT AVG(costs)
    FROM repairs
);

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одно строки значения.
-- Вставляет нового пользователя
INSERT INTO users (id, first_name, last_name, phone_number, email)
VALUES (1001, 'Нису', 'Нисуев', '+7 (916) 699 16-60' , 'nisuev04@mail.ru');

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
-- Добавляет машину к пользователю с почтой nisuev04@mail.ru
INSERT INTO cars (user_id, brand, model, release_year, vin, plate)
SELECT 
    (SELECT id FROM users WHERE email = 'nisuev04@mail.ru'), 
    'Honda' AS brand,
    'Civic' AS model,
    2022 AS release_year,
    '2HGFC2F5XKH123456' AS vin,
    'А777АА77' AS plate
WHERE NOT EXISTS (
    SELECT 1 
    FROM cars 
    WHERE vin = '2HGFC2F5XKH123456'
);

-- 18. Простая инструкция UPDATE.
-- Увеличение стоимости ремонта в 1.5 раз
UPDATE repairs
SET costs = costs * 0.5
WHERE repair_type = 'Полировка';

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- обновляет стоимость 52 ремонта на среднюю стоимость оконченных ремонтов
UPDATE repairs
SET costs = (
    SELECT AVG(costs)
    FROM repairs
    WHERE repair_status = 'Ремонт окончен'
)
WHERE id = 52;

-- 20. Простая инструкция DELETE.
-- Удаляет все отданные клиентом запросы
DELETE FROM requests
WHERE request_status = 'Получен клиентом';

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
-- Удаляет машины которых не было в заявках
DELETE FROM cars
WHERE id IN (
    SELECT c.id
    FROM cars c
    LEFT JOIN requests r ON c.id = r.car_id
    WHERE r.car_id IS NULL
);

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- Среднее количество запросов замены шин на автомобилях
WITH CarRequests (car_id, RequestCount) AS (
    SELECT car_id, COUNT(*) AS RequestCount
    FROM requests rq
    JOIN repairs rp ON rp.request_id = rq.id
    WHERE rp.repair_type = 'Замена шин' 
    GROUP BY car_id
)
SELECT AVG(RequestCount) AS "Среднее количество замены шин на автомобилях"
FROM CarRequests;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
-- Выводит все машины человека с номером '+7 (984) 419 29-53'
WITH RECURSIVE RecursiveCars (user_id, car_id, brand, model, release_year, Level) AS (
    SELECT u.id, c.id, c.brand, c.model, c.release_year, 1 AS Level
    FROM users u
    JOIN cars c ON u.id = c.user_id
    WHERE u.phone_number = '+7 (984) 419 29-53'
    
    UNION ALL
    
    SELECT rc.user_id, c.id, c.brand, c.model, c.release_year, rc.Level + 1
    FROM RecursiveCars rc
    JOIN cars c ON c.user_id = rc.user_id
    WHERE c.id <> rc.car_id
)
-- Вывод результата
SELECT user_id, car_id, brand, model, release_year, Level
FROM RecursiveCars
ORDER BY Level;

-- 24. Оконные функции. Использование конструкци MIN/MAX/AVG OVER()
-- Считает минимальные, максимальные и средние значения по стоимости ремонта для каждой машины
SELECT 
    c.id AS car_id, 
    c.brand,
    c.model,
    AVG(r.costs) OVER(PARTITION BY c.brand) AS AvgCosts,
    MIN(r.costs) OVER(PARTITION BY c.brand) AS MinCosts,
    MAX(r.costs) OVER(PARTITION BY c.brand) AS MaxCosts
FROM cars c
JOIN repairs r ON c.id = r.request_id;

-- 25. Оконные фнкции для устранения дублей
-- Оставляет у каждого пользователя одну машину
WITH CarsWithRowNumber AS (
    SELECT 
        id, 
        brand, 
        model, 
        release_year, 
        vin, 
        plate, 
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY id) AS row_num
    FROM cars
)
DELETE FROM cars
WHERE id IN (
    SELECT id
    FROM CarsWithRowNumber
    WHERE row_num > 1
);

-- Защита
-- Найти всех работников сгруппировать по специальностям отсортировать по последнему ремонту
SELECT 
    w.id,
    w.first_name, 
    w.last_name, 
    w.specialization, 
    rp.repair_date,
    ROW_NUMBER() OVER (PARTITION BY w.specialization ORDER BY rp.repair_date DESC) AS repair_rank
FROM workers w
JOIN repairs rp ON w.id = rp.worker_id
