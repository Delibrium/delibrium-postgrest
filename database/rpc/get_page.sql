create or replace function aula.get_page(space_id bigint, page_name text)
  returns json
  language plpgsql
as $$
declare
  page text;
  begin
    select aula.school.pages->page_name from aula.school where id = space_id into page;
    return page;
  end
$$;
