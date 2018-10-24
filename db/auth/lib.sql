create extension if not exists pgcrypto;
create extension if not exists pgjwt;
create language plpython3u;

create or replace function delibrium_secure.encrypt_pass()
  returns trigger
  language plpgsql
as $$
begin
  if tg_op = 'INSERT' or new.password <> old.password then
    new.password = crypt(new.password, gen_salt('bf'));
  end if;
  return new;
end
$$;

-- Use always encrypt_pass function to change password values
drop trigger if exists encrypt_pass on delibrium_secure.user_login;
create trigger encrypt_pass
  before insert or update on delibrium_secure.user_login
  for each row
  execute procedure delibrium_secure.encrypt_pass();

drop function delibrium_secure.user_id(text,text);
create or replace function delibrium_secure.user_id(in username text, in password text)
  returns table (uid bigint, sc integer)
  language plpgsql
as $$
begin
  set "request.jwt.claim.user_group" TO 'admin';

  return query select delibrium.users.id, delibrium_secure.user_login.session_count
              from delibrium.users, delibrium_secure.user_login where delibrium.users.id = delibrium_secure.user_login.delibrium_user_id and
                   delibrium.users.email = user_id.username  and
                   delibrium_secure.user_login.password = crypt(user_id.password, delibrium_secure.user_login.password);
end;
$$;

drop function delibrium.logout();
create or replace function delibrium.logout()
  returns void
  language plpython3u
as $$
  import json
  maybe_user_id = plpy.execute("select current_setting('request.jwt.claim.user_id', true)")[0]['current_setting']
  if maybe_user_id:
    user_id = int(maybe_user_id)
    plpy.execute('update delibrium_secure.user_login set session_count = session_count + 1 where delibrium_user_id = {}'.format(user_id))
  else:
    plpy.execute('''set local "response.headers" = '[{"set-cookie": "sessiontoken=;Path=/;domain=localhost;"}]';''')

$$;



CREATE TYPE delibrium_secure.jwt_token AS (
   token text
);

drop function delibrium.login(text, text);
create or replace function delibrium.login(username text, password text)
  returns json
  language plpython3u
as $$
  import json

  rv = plpy.execute('select * from delibrium_secure.user_id(\'{}\', \'{}\')'.format(username, password))
  plpy.execute('set "request.jwt.claim.user_group" TO \'\'')
  plpy.info(rv)

  if rv:
    delibrium_user_id = int(rv[0]['uid'])
    session_count = int(rv[0]['sc'])
  else:
    plpy.error('authentication failed', sqlstate='PT401')
    return 'authentication failed'

  plpy.info("INFO >>", delibrium_user_id, session_count)

  plpy.execute('set "request.jwt.claim.user_group" TO \'admin\'')
  rv = plpy.execute('select group_id, community_id from delibrium.user_group where user_id = {}'.format(delibrium_user_id))

  community_id = rv[0]['community_id']
  group_id = rv[0]['group_id']
  plpy.execute('set "request.jwt.claim.user_group" TO \'{}\''.format(group_id))
  plpy.info(community_id)

  rv = plpy.execute('''select sign(
      row_to_json(r), current_setting('app.jwt_secret')
    ) as token
    from (
      select '{}' as user_group, '{}' as community_id, 'delibrium_authenticator'  as role, '{}' as user_id, '{}' as session_count,
         extract(epoch from now())::integer + 60*60*24*31 as exp
    ) r'''.format(group_id, community_id, delibrium_user_id, session_count))

  token = rv[0]['token']

  plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}, {{"access-control-allow-origin": "*"}}]\''.format(token, token))

  user_data = {'role': group_id, 'community_id': community_id, 'user_id': delibrium_user_id }
  output = {'status': 'success', 'data': user_data}

  return json.dumps(output)
$$;

create or replace function delibrium.refresh_token()
  returns text
as $$
declare
  usr record;
  token text;
begin
    raise info 'TOKEN %', current_setting('request.jwt', true);

    EXECUTE format(
    ' select row_to_json(u.*) as j'
        ' from delibrium_secure.user_login as u'
        ' where u.delibrium_user_id = cast($1 as numeric)')
    INTO usr
    USING current_setting('request.jwt.claim.user_id', true);

    if usr is NULL then
      raise exception 'user not found';
    else
      select sign(
       current_setting('request.jwt', true), current_setting('app.jwt_secret')
      )
      into token;
      return token;
    end if;
end
$$ stable security definer language plpgsql;
