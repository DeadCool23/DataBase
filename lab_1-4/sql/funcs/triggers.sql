CREATE OR REPLACE FUNCTION update_request_status_after_repair()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE requests
    SET request_status = 'В очереди'
    WHERE id = NEW.request_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_repair_insert
AFTER INSERT ON repairs
FOR EACH ROW
EXECUTE FUNCTION update_request_status_after_repair();

-- ==================================================================================

CREATE OR REPLACE FUNCTION log_requeste_date()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'New request: [id = %, status = %, date = %]', NEW.id, NEW.request_status, CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW req_log AS
SELECT id, request_status, request_date
FROM requests;

CREATE TRIGGER before_request_insert
INSTEAD OF INSERT ON req_log
FOR EACH ROW
EXECUTE FUNCTION log_requeste_date();
