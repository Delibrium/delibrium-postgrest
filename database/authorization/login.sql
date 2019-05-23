create or replace function aula.login(school_id bigint, username text, password text)
  returns json
  language plpython3u
  set search_path = public, aula
as $$
  import json
  import time

  rv = plpy.execute('select * from aula_secure.user_id(\'{}\', \'{}\', \'{}\')'.format(school_id, username, password))
  plpy.execute('set "request.jwt.claim.user_group" TO \'\'')

  if rv:
    aula_user_id = int(rv[0]['uid'])
    session_count = int(rv[0]['sc'])
  else:
    plpy.error('authentication failed', sqlstate='PT401')
    return 'authentication failed'

  plpy.execute('set "request.jwt.claim.user_group" TO \'admin\'')
  rv = plpy.execute('select group_id,idea_space from aula.user_group where user_id = {}'.format(aula_user_id))

  all_roles = []
  for r in rv:
    role = [r['group_id']]
    space = r['idea_space']
    if space:
      role += [space]
    all_roles += [role]

  plpy.execute('set "request.jwt.claim.roles" TO \"{}\"'.format(all_roles))

  group_id = rv[0]['group_id']
  plpy.execute('set "request.jwt.claim.user_group" TO \'{}\''.format(group_id))

  token = {
    'user_group': group_id,
    'school_id': school_id,
    'role': 'aula_authenticator',
    'roles': all_roles,
    'user_id': aula_user_id,
    'session_count': session_count,
    'exp': int(time.time()) + 60*60*24*31
  }

  rv = plpy.execute('''select pgjwt.sign(
       '{}', current_setting('app.jwt_secret')
       ) as token'''.format(json.dumps(token)))

  token = rv[0]['token']

  plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}]\''.format(token, token))

  user_data = {'role': group_id, 'school_id': school_id, 'user_id': aula_user_id }
  output = {'status': 'success', 'data': user_data}

  return json.dumps(output)
$$;

grant execute on function aula.login(bigint, text, text) to aula_authenticator;
