-- Таблица cars
ALTER TABLE cars
    ADD CONSTRAINT check_id CHECK (id > 0),
    ADD CONSTRAINT check_release_year CHECK (release_year >= 1886 AND release_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    ADD CONSTRAINT check_vin_length CHECK (LENGTH(vin) = 17),
    ALTER COLUMN vin SET NOT NULL,
    ADD CONSTRAINT vin_unique UNIQUE (vin),
    ADD CONSTRAINT check_plate_format CHECK (plate ~ '^[АВЕКМНОРСТУХ]{1}\d{3}[АВЕКМНОРСТУХ]{2}\d{2,3}$'),
    ALTER COLUMN plate SET NOT NULL,
    ADD CONSTRAINT plate_unique UNIQUE (plate),
    ALTER COLUMN model SET NOT NULL,
    ALTER COLUMN brand SET NOT NULL;

-- Таблица users
ALTER TABLE users
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN first_name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    ADD CONSTRAINT check_phone CHECK (phone_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2}-[0-9]{2}$'),
    ALTER COLUMN phone_number SET NOT NULL,
    ADD CONSTRAINT check_email CHECK (email ~ '^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+$'),
    ALTER COLUMN email SET NOT NULL;

-- Таблица workers
ALTER TABLE workers
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN first_name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    ALTER COLUMN specialization SET NOT NULL,
    ADD CONSTRAINT check_phone CHECK (phone_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2}-[0-9]{2}$'),
    ALTER COLUMN phone_number SET NOT NULL,
    ADD CONSTRAINT check_experience CHECK (work_experience > 0);

-- Таблица requests
ALTER TABLE requests
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN request_status SET NOT NULL,
    ALTER COLUMN car_id SET NOT NULL,
    ALTER COLUMN request_date SET NOT NULL;

-- Таблица repairs
ALTER TABLE repairs
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN worker_id SET NOT NULL,
    ALTER COLUMN request_id SET NOT NULL,
    ALTER COLUMN repair_status SET NOT NULL,
    ALTER COLUMN repair_type SET NOT NULL,
    ALTER COLUMN repair_date SET NOT NULL,
    ADD CONSTRAINT check_cost CHECK (costs > 0);