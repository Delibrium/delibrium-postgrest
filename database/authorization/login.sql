create or replace function aula.login(school_id bigint, username text, password text)
  returns json
  language plpython3u
  set search_path = public, aula
as $$
  import json

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

  group_id = rv[0]['group_id']
  plpy.execute('set "request.jwt.claim.user_group" TO \'{}\''.format(group_id))
  plpy.info(school_id)

  rv = plpy.execute('''select sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    from (
      select '{}' as user_group, '{}' as school_id, 'aula_authenticator'  as role, '{}' as user_id, '{}' as session_count,
         extract(epoch from now())::integer + 60*60*24*31 as exp
    ) r'''.format(group_id, school_id, aula_user_id, session_count))

  token = rv[0]['token']

  plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}, {{"access-control-allow-origin": "*"}}]\''.format(token, token))

  user_data = {'role': group_id, 'school_id': school_id, 'user_id': aula_user_id }
  output = {'status': 'success', 'data': user_data}

  return json.dumps(output)
$$;
