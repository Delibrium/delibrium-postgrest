create or replace function aula.get_page(school_id bigint, page_name text)
  returns json
  language plpgsql
as $$
declare
  page text;
  begin
    select content from aula.page where school_id = school_id into page;
    return page;
  end
$$;

grant execute on function aula.get_page(bigint,text) to aula_authenticator;
