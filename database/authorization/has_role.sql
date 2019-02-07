create or replace function aula.has_role(role text, space_id, school_id bigint)
  returns boolean
  language plpython3u
  set search_path = public, aula
as $$

  res = plpy.execute("select current_setting('request.jwt.claim.roles', true) as roles")
  roles = r[0]['roles']

  for r in roles:
    if len(r) == 1:
     if role == r[0] and not space_id:
      return True
    elsif role == r[0] and r[1] == space_id:
      return True

  return False
$$;
