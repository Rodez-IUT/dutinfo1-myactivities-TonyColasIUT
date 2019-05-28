DROP TRIGGER IF EXISTS log_register_user_on_activity on registration ;
DROP TRIGGER IF EXISTS log_unregister_user_on_activity on registration ;

create or replace function register_user_on_activity(in_user_id bigint, in_activity_id bigint)
    returns registration as $$
    declare
        res_registration registration%rowtype;
    begin
        -- check existence
        select * into res_registration from registration
        where user_id = in_user_id and activity_id = in_activity_id;
        if FOUND then
            raise exception 'registration_already_exists';
        end if;
        -- insert
        insert into registration (id, user_id, activity_id)
        values(nextval('id_generator'), in_user_id, in_activity_id);
        -- returns result
        select * into res_registration from registration
        where user_id = in_user_id and activity_id = in_activity_id;
        return res_registration;
    end;
$$ language plpgsql;

/*
CREATE OR REPLACE FUNCTION register_user_on_activity(user_id bigint, activity_id bigint) RETURNS registration AS $$
DECLARE
	ligneReg registration%ROWTYPE;
BEGIN
    -- récupérer si la ligne est existante
	SELECT * INTO ligneReg FROM registration as R
	WHERE R.user_id = user_id
	AND R.activity_id = activity_id;
	
	-- IF FOUND ERROR ELSE INSERT 
	IF FOUND THEN
	    RAISE EXCEPTION 'registration_already_exists';
	END IF;
    INSERT INTO registration (id, user_id, activity_id) 
    VALUES (nextval('id_generator'), user_id, activity_id);
    
    SELECT * INTO ligneReg FROM registration as R
	WHERE R.user_id = user_id
	AND R.activity_id = activity_id;-
	RETURN ligneReg;
    
END;
$$ LANGUAGE plpgsql;
*/

CREATE OR REPLACE FUNCTION unregister_user_on_activity(in_user_id bigint, in_activity_id bigint) RETURNS void AS $$
DECLARE
BEGIN
	-- récupérer si la ligne est existante
	PERFORM * FROM registration
	WHERE in_user_id = user_id
	AND in_activity_id = activity_id;
	
	-- IF NOT FOUND ERROR ELSE delete 
	IF NOT FOUND THEN
	    RAISE EXCEPTION 'registration_not_found';
	END IF;
	
    DELETE FROM registration 
	WHERE in_user_id = user_id
	AND in_activity_id = activity_id;
END;
$$ LANGUAGE plpgsql;

-- fonction trigger
CREATE OR REPLACE FUNCTION log_register_user_on_activity()
    RETURNS TRIGGER AS $$
BEGIN
     INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
        values  (nextval('id_generator'),'insert', 'registration', NEW.id, user, now());
     RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$$ language plpgsql;

-- fonction trigger
CREATE OR REPLACE FUNCTION log_unregister_user_on_activity()
    RETURNS TRIGGER AS $$
BEGIN
     INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
        values  (nextval('id_generator'), 'delete', 'registration', OLD.id, user, now());
     RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER
END;
$$ language plpgsql;
   
-- trigger
CREATE TRIGGER log_register_user_on_activity
    AFTER INSERT ON registration
    FOR EACH ROW EXECUTE PROCEDURE log_register_user_on_activity();
    
-- trigger
CREATE TRIGGER log_unregister_user_on_activity
    AFTER DELETE ON registration
    FOR EACH ROW EXECUTE PROCEDURE log_unregister_user_on_activity();
    
