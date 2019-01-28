create or replace function aula.update_page(space_id bigint, page text, content text)
  returns void
  language plpgsql
as $$
  begin
  update aula.school set pages = jsonb_set(pages, array_append(array[]:: text[], page), to_jsonb(content)) where id = space_id;
  end
$$;
