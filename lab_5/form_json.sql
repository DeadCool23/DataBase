COPY (SELECT array_to_json(array_agg(row_to_json(usr))) FROM users as usr)
TO '/your/pass/to/users.json';

SELECT row_to_json(usr) FROM users as usr;

CREATE TABLE users_json (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(18) UNIQUE,
    email VARCHAR(50) UNIQUE
);

ALTER TABLE users_json
    ADD CONSTRAINT check_id CHECK (id > 0),
    ALTER COLUMN first_name SET NOT NULL,
    ALTER COLUMN last_name SET NOT NULL,
    ADD CONSTRAINT check_phone CHECK (phone_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2}-[0-9]{2}$'),
    ALTER COLUMN phone_number SET NOT NULL,
    ADD CONSTRAINT check_email CHECK (email ~ '^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+$'),
    ALTER COLUMN email SET NOT NULL;

CREATE TEMP TABLE tmp_users_json(data json);

COPY tmp_users_json FROM '/your/pass/to/users.json';

INSERT INTO users_json
SELECT (json_populate_record(null::users_json, json_array_elements(data))).* FROM tmp_users_json;

SELECT * FROM users_json
ORDER BY id;