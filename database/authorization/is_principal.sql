create or replace function aula.is_principal(school_id bigint)
  returns boolean
  language plpython3u
as $$
  r = plpy.execute("select current_setting('request.jwt.claim.roles', true);")
  return 'principal' in r[0]['current_setting']
$$;
