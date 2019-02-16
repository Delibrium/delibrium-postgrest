create or replace function request.cookie(c text) returns text as $$
    select request.env_var('request.cookie.' || c);
$$ stable language sql;
