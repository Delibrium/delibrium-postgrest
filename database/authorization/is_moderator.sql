create or replace function aula.is_moderator(school_id bigint)
  returns boolean
  language plpython3u
  set search_path = public, aula
as $$

  r = plpy.execute("select current_setting('request.jwt.claim.roles', true) as roles")
  roles =  r[0]['roles']

  return 'moderator' in roles

$$;
