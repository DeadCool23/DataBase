DROP TABLE IF EXISTS user_info;
CREATE TABLE IF NOT EXISTS user_info (
    id SERIAL PRIMARY KEY,
    user_id  INT,
    data JSONB
);

INSERT INTO user_info (user_id, data)
VALUES
(1, '{"first_name":"Владлен","last_name":"Кузьмин","patronomic":"Андреевич","phone_number":"+7 (975) 129 46-23","email":"evstigne_14@gmail.com", "repairs":[]}'),
(9, '{"first_name":"Евгений","last_name":"Мишин","phone_number":"+7 (965) 487 28-49","email":"voronovzahar@hotmail.com", "repairs":["Покраска"]}'),
(31, '{"id":31,"first_name":"Григорий","last_name":"Беспалов","phone_number":"+7 (994) 326 81-34","email":"ukuzmin@yahoo.com", "repairs":["Покраска", "Полировка"]}');

SELECT * FROM user_info;

-- 1. Извлечь JSON фрагмент из JSON документа

SELECT 
  first_name,
  last_name,
  data->'repairs' as achievements
FROM user_info JOIN users ON users.id = user_info.user_id;

-- 2. Извлечь значения конкретных узлов или атрибутов JSON документа

SELECT 
  first_name,
  last_name,
  data->>'email' as iq
FROM user_info JOIN users ON users.id = user_info.user_id;

-- 3. Выполнить проверку существования узла или атрибута 

SELECT 
  first_name,
  last_name,
  data->>'patronomic' as patronomic
FROM user_info JOIN users ON users.id = user_info.user_id
WHERE data->>'patronomic' IS NOT NULL;

-- 4. Изменить XML/JSON документ

UPDATE user_info
SET data = jsonb_set(data, '{patronomic}', '"Нет отчества"', TRUE)
WHERE data->>'patronomic' IS NULL;

SELECT 
  first_name,
  last_name,
  data->>'patronomic' as mom_comment
FROM user_info JOIN users ON users.id = user_info.user_id
WHERE data->>'patronomic' IS NOT NULL;

-- 5. Разделить JSON документ на несколько строк по узлам
WITH tmp AS (
  SELECT data->'repairs' as arr FROM user_info
)
SELECT jsonb_array_elements_text(tmp.arr) FROM tmp;







