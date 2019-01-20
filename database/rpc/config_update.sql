create or replace function aula.config_update(space_id bigint, key text, value text)
  returns void
  language plpgsql
as $$
  begin
  update aula.school set config = jsonb_set(config, array_append(array[]:: text[], key), to_jsonb(value)) where id = space_id;
  end
$$;
