create or replace function request.jwt_claim(c text) returns text as $$
    select request.env_var('request.jwt.claim.' || c);
$$ stable language sql;
