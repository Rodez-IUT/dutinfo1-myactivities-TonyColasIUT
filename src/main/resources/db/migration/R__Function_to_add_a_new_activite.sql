--DROP FUNCTION add_activity_with_title(varchar);
CREATE OR REPLACE FUNCTION add_activity_with_title(title varchar(50)) RETURNS bigint AS $$
    INSERT INTO activity (id,title)
    VALUES (nextval('id_generator'), title)
    RETURNING id;
$$ LANGUAGE SQL