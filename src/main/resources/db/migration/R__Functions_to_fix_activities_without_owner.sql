
CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
DECLARE
    defaultOwner "user"%rowtype;
    stringUser varchar(50) = 'Default Owner';
BEGIN
	SELECT * INTO defaultOwner FROM "user" 
      WHERE username = stringUser;
	IF NOT FOUND THEN 
	    INSERT INTO "user" (id, username)
	      VALUES (nextval('id_generator'), stringUser);
	    SELECT * INTO defaultOwner FROM "user" 
	      WHERE username = stringUser;
	END IF;
	RETURN defaultOwner;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
DECLARE 
    defaultOwner "user"%rowtype;
    nowDate date = now();
BEGIN
    defaultOwner = get_default_owner();
	RETURN QUERY UPDATE activity
    SET owner_id = defaultOwner.id,
        modification_date = nowDate
        WHERE owner_id IS NULL
        RETURNING *;
END
$$ LANGUAGE plpgsql;