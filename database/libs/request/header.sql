create or replace function request.header(h text) returns text as $$
    select request.env_var('request.header.' || h);
$$ stable language sql;
