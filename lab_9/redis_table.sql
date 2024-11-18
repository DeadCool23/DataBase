CREATE TABLE users_redis (  
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(18) UNIQUE,
    email VARCHAR(50) UNIQUE
);

ALTER TABLE users_redis 
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN first_name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    ADD CONSTRAINT check_phone CHECK (phone_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2}-[0-9]{2}$'),
    ALTER COLUMN phone_number SET NOT NULL,
    ADD CONSTRAINT check_email CHECK (email ~ '^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+$'),
    ALTER COLUMN email SET NOT NULL;