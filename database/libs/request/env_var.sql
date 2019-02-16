create or replace function request.env_var(v text) returns text as $$
    select current_setting(v, true);
$$ stable language sql;
