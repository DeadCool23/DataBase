-- Импорт данных в таблицу users
\copy users (id, first_name, last_name, phone_number, email) FROM '/media/sf_Programms/DataBase/lab_01/data/users_data.csv' DELIMITER ',' CSV HEADER;

-- Импорт данных в таблицу cars
\copy cars (id, user_id, brand, model, release_year, vin, plate) FROM '/media/sf_Programms/DataBase/lab_01/data/cars_data.csv' DELIMITER ',' CSV HEADER;

-- Импорт данных в таблицу requests
\copy requests (id, car_id, request_status, request_date) FROM '/media/sf_Programms/DataBase/lab_01/data/requests_data.csv' DELIMITER ',' CSV HEADER;

-- Импорт данных в таблицу workers
\copy workers (id, first_name, last_name, phone_number, specialization, work_experience) FROM '/media/sf_Programms/DataBase/lab_01/data/workers_data.csv' DELIMITER ',' CSV HEADER;

-- Импорт данных в таблицу repairs
\copy repairs (id, worker_id, request_id, repair_status, repair_type, costs, repair_date) FROM '/media/sf_Programms/DataBase/lab_01/data/repairs_data.csv' DELIMITER ',' CSV HEADER;