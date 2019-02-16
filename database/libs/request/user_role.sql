create or replace function request.user_role() returns text as $$
    select request.jwt_claim('role')::text;
$$ stable language sql;
