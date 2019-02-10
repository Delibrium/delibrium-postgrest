create or replace function aula.update_page(school_id bigint, page text, content text)
  returns void
  language plpgsql
as $$
  begin
  update aula.page set content = content where name = page and school_id = school_id;
  end
$$;
