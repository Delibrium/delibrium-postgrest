create or replace function aula.has_role(role text, space_id bigint default null)
  returns boolean
  language plpython3u
  set search_path = public, aula
as $$
  import json
  res = plpy.execute("select current_setting('request.jwt.claim.roles', true);")

  roles = json.loads(res[0]['current_setting'])

  for r in roles:
    if len(r) == 2 and space_id is not null:
      if role == r[0] and r[1] == space_id:
        return True
    elif len(r) == 1:
      if r[0] == role:
        return True

  return False
$$;
