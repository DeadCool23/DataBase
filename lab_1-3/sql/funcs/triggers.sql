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

CREATE OR REPLACE FUNCTION set_request_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.request_date := CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_request_insert
BEFORE INSERT ON requests
FOR EACH ROW
EXECUTE FUNCTION set_request_date();

