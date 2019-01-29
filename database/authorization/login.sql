create or replace function aula.login(school_id bigint, username text, password text)
  returns json
  language plpython3u
  set search_path = public, aula
as $$
  import json
  import time

  rv = plpy.execute('select * from aula_secure.user_id(\'{}\', \'{}\', \'{}\')'.format(school_id, username, password))
  plpy.execute('set "request.jwt.claim.user_group" TO \'\'')
  plpy.info(rv)

  if rv:
    aula_user_id = int(rv[0]['uid'])
    session_count = int(rv[0]['sc'])
  else:
    plpy.error('authentication failed', sqlstate='PT401')
    return 'authentication failed'

  plpy.info("INFO >>", aula_user_id, session_count)


  plpy.execute('set "request.jwt.claim.user_group" TO \'admin\'')
  rv = plpy.execute('select group_id from aula.user_group where user_id = {}'.format(aula_user_id))

  all_roles = [r['group_id'] for r in rv]
  plpy.info('set "request.jwt.claim.roles" TO \"{}\"'.format(all_roles))
  plpy.execute('set "request.jwt.claim.roles" TO \"{}\"'.format(all_roles))

  group_id = rv[0]['group_id']
  plpy.execute('set "request.jwt.claim.user_group" TO \'{}\''.format(group_id))
  plpy.info(school_id)

  token = {
    'user_group': group_id,
    'school_id': school_id,
    'role': 'aula_authenticator',
    'roles': all_roles,
    'user_id': aula_user_id,
    'session_count': session_count,
    'exp': int(time.time()) + 60*60*24*31
  }

  rv = plpy.execute('''select sign(
       '{}', current_setting('app.jwt_secret')
       ) as token'''.format(json.dumps(token)))

  token = rv[0]['token']

  plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}, {{"access-control-allow-origin": "*"}}]\''.format(token, token))

  user_data = {'role': group_id, 'school_id': school_id, 'user_id': aula_user_id }
  output = {'status': 'success', 'data': user_data}

  return json.dumps(output)
$$;
