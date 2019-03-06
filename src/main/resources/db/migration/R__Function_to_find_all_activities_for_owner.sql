DROP FUNCTION find_all_activities_for_owner(varchar);
CREATE OR REPLACE FUNCTION find_all_activities_for_owner(nom varchar(50)) RETURNS SETOF activity AS $$
    SELECT * FROM activity AS a
    WHERE owner_id = ( SELECT id FROM "user" 
                       WHERE nom = username)
$$ LANGUAGE SQL