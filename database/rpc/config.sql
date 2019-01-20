create or replace function aula.config(space_id bigint)
  returns json
  language plpgsql
as $$
declare
  config json;
  begin
    select aula.school.config from aula.school where id = space_id into config;
    return config;
  end
$$;
