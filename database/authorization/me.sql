create or replace function aula.me()
  returns json
  language plpython3u
as $$
import json

maybe_user_id = plpy.execute("select current_setting('request.jwt.claim.user_id', true)")[0]['current_setting']
if maybe_user_id:
  usr = plpy.execute('select * from aula.users where id = {}'.format(maybe_user_id))[0]
  roles = plpy.execute('select * from aula.user_group where user_id = {}'.format(maybe_user_id))

  usr['role_details'] = list(roles)
  usr['role'] = list(set([r['group_id'] for r in roles]))

  plpy.execute('set "request.jwt.claim.user_group" TO \'admin\'')
  rv = plpy.execute('select group_id,idea_space from aula.user_group where user_id = {}'.format(maybe_user_id))

  all_roles = []
  for r in rv:
    role = [r['group_id']]
    space = r['idea_space']
    if space:
      role += [space]
    all_roles += [role]

  usr['roles'] = all_roles

  return json.dumps(usr)
$$;
