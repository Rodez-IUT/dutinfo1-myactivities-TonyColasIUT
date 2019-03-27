
CREATE OR REPLACE FUNCTION trigger_to_log_action() RETURNS trigger  AS $$
DECLARE 

BEGIN
    INSERT INTO action_log
    SELECT nextval('id_generator'),'delete', 'activity', user, OLD.id;
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_to_log_action AFTER DELETE ON activity
    FOR EACH ROW EXECUTE PROCEDURE trigger_to_log_action();