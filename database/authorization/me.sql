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

  return json.dumps(usr)
$$;
