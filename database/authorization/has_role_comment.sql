create or replace function aula.has_role_comment(role text, idea_id bigint, school_id bigint)
  returns boolean
  language plpython3u
  set search_path = public, aula
as $$
  import json

  res = plpy.execute("select current_setting('request.jwt.claim.roles', true) as roles")
  roles = json.loads(res[0]['roles'])

  space_id_plan = plpy.prepare("select idea_space from aula.idea where id = $1", ["bigint"])
  res = plpy.execute(space_id_plan, [idea_id])

  space_id = res[0]["idea_space"]

  for r in roles:
    if len(r) == 1:
     if role == r[0] and not space_id:
      return True
    elif role == r[0] and r[1] == space_id:
        return True

  return False
$$;

grant execute on function aula.has_role_comment(aula.group_id, bigint, bigint) to aula_authenticator;
