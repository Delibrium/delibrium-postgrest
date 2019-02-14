create or replace function aula.from_space(role text, space_id bigint)
  returns boolean
  language plpython3u
  set search_path = public, aula
as $$
  import json
  res = plpy.execute("select current_setting('request.jwt.claim.roles', true);")

  roles = json.loads(res[0]['current_setting'])

  for r in roles:
    if len(r) == 2:
      if role == r[0] and r[1] == space_id:
        return True

  return False
$$;
