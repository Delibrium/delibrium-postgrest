create or replace function aula.logout()
  returns void
  language plpython3u
as $$
  import json
  maybe_user_id = plpy.execute("select current_setting('request.jwt.claim.user_id', true)")[0]['current_setting']
  if maybe_user_id:
    user_id = int(maybe_user_id)
    plpy.execute('update aula_secure.user_login set session_count = session_count + 1 where aula_user_id = {}'.format(user_id))
  else:
    plpy.execute('''set local "response.headers" = '[{"set-cookie": "sessiontoken=;Path=/;domain=localhost;"}]';''')
$$;
