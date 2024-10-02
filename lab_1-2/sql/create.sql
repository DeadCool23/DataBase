CREATE DATABASE  autoservice;

\c autoservice;

CREATE TABLE users (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(18) UNIQUE,
    email VARCHAR(50) UNIQUE
);

CREATE TABLE cars (
    id INT PRIMARY KEY,
    user_id INT REFERENCES users(id),
    brand VARCHAR(50),
    model VARCHAR(50),
    release_year INT,
    vin VARCHAR(17),
    plate VARCHAR(10)
);

CREATE TABLE workers (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(18),
    specialization VARCHAR(50),
    work_experience DOUBLE PRECISION
);

CREATE TABLE requests (
    id INT PRIMARY KEY,
    car_id INT REFERENCES cars(id),
    request_status VARCHAR(50),
    request_date DATE
);

CREATE TABLE repairs (
    id INT PRIMARY KEY,
    worker_id INT REFERENCES workers(id),
    request_id INT REFERENCES requests(id),
    repair_status VARCHAR(50),
    repair_type VARCHAR(50),
    costs DOUBLE PRECISION,
    repair_date DATE
);