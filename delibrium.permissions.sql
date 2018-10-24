drop function delibrium_secure.change_password(bigint, text);
create or replace function delibrium_secure.change_password(user_id bigint, new_password text)
   returns void
   language plpgsql
as $$
declare
  community_id bigint;
 begin
 raise info 'CHANGE PASS: user_group => %, community_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.community_id', true);
  if current_setting('request.jwt.claim.user_group') = 'admin' then
    select delibrium.users.community_id into community_id from delibrium.users where  delibrium.users.id = user_id;
  else
    community_id := cast(current_setting('request.jwt.claim.community_id') as numeric);
  end if;

   insert into delibrium_secure.user_login (community_id, delibrium_user_id, password) values (community_id, user_id, new_password)
    on conflict (delibrium_user_id) do update set password = new_password;
 end
$$;

drop function delibrium.change_password(bigint, text);
create or replace function delibrium.change_password(user_id bigint, password text)
   returns void
   language plpgsql
as $$
 begin
 raise info 'CHANGE PASS: user_group => %, community_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.community_id', true);
   perform delibrium_secure.change_password(user_id, password);
 end
$$;

drop function delibrium.config_update(bigint, text, text);
create or replace function delibrium.config_update(space_id bigint, key text, value text)
  returns void
  language plpgsql
as $$
  begin
  update delibrium.community set config = jsonb_set(config, array_append(array[]:: text[], key), to_jsonb(value)) where id = space_id;
  end
$$;

drop function delibrium.config(bigint);
create or replace function delibrium.config(space_id bigint)
  returns json
  language plpgsql
as $$
declare
  config json;
  begin
    select delibrium.community.config from delibrium.community where id = space_id into config;
    return config;
  end
$$;


create or replace function delibrium.me()
  returns json
  language plpython3u
as $$
import json

maybe_user_id = plpy.execute("select current_setting('request.jwt.claim.user_id', true)")[0]['current_setting']
if maybe_user_id:
  usr = plpy.execute('select * from delibrium.users where id = {}'.format(maybe_user_id))[0]
  roles = plpy.execute('select * from delibrium.user_group where user_id = {}'.format(maybe_user_id))

  usr['role_details'] = list(roles)
  usr['role'] = list(set([r['group_id'] for r in roles]))

  return json.dumps(usr)
$$;



create or replace function delibrium_secure.check_user()
 returns void
 language plpgsql
as $$
declare
  user_id integer;
  user_role text;
  session_count_claim integer;
  session_count integer;
begin
--  user_role := current_setting(request.jwt.claim.user_group);
--  if user_role = '' then
--    raise exception 'session not valid';
--  end if;
  raise info 'HEADER %', current_setting('request.header.x-uri', true);

  if current_setting('request.jwt.claim.user_id', true) != '' then
    raise info 'user_id %', current_setting('request.jwt.claim.user_id', true) = '';
    user_id := current_setting('request.jwt.claim.user_id', true);
  else
    return;
  end if;
  if current_setting('request.jwt.claim.session_count', true) != '' then
    raise info '%', current_setting('request.jwt.claim.session_count', true);
    session_count_claim := current_setting('request.jwt.claim.session_count', true);
  else
    return;
  end if;

  raise info 'Checking with % %', user_id, session_count_claim;

  if user_id is not null and session_count_claim is not null then
    select delibrium_secure.user_login.session_count into session_count from delibrium_secure.user_login where delibrium_user_id = cast(user_id as numeric);
    if session_count > cast(session_count_claim as numeric) then
      raise exception 'session expired'
        using hint = 'login again', detail = '';
    end if;
  end if;
end
$$;

create or replace function delibrium.is_owner(user_id bigint)
  returns boolean
  language plpgsql
as $$
begin
  return (cast(current_setting('request.jwt.claim.user_id') as numeric) = user_id);
end
$$;

create or replace function delibrium.is_admin(community_id bigint)
  returns boolean
  language plpgsql
as $$
declare
  gid delibrium.group_id;
begin
  raise info 'CHECK IS ADMIN';
  raise info 'user_group => %, community_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.community_id', true);
  return (current_setting('request.jwt.claim.user_group', true) = 'admin') or (cast(current_setting('request.jwt.claim.community_id', true) as "numeric") = community_id and current_setting('request.jwt.claim.user_group', true) = 'community_admin');
end
$$;

-- Login

create extension if not exists pgcrypto;
create extension if not exists pgjwt;

create or replace function
delibrium_secure.encrypt_pass() returns trigger
  language plpgsql
  as $$
begin
  if tg_op = 'INSERT' or new.password <> old.password then
    new.password = crypt(new.password, gen_salt('bf'));
  end if;
  return new;
end
$$;

drop trigger if exists encrypt_pass on delibrium_secure.user_login;
create trigger encrypt_pass
  before insert or update on delibrium_secure.user_login
  for each row
  execute procedure delibrium_secure.encrypt_pass();

drop function delibrium_secure.user_id(text,text);
create or replace function
delibrium_secure.user_id(in username text, in password text)
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

CREATE TYPE delibrium_secure.jwt_token AS (
   token text
);

create language plpython3u;

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

  # plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}, {{"set-cookie": "sessiontoken={};path=/"}}, {{"Path": "/"}}, {{"Domain": "localhost"}}, {{"access-control-allow-origin": "*"}}]\''.format(token, token))
  plpy.execute('set local "response.headers" = \'[{{"Authorization": "Bearer {}"}}, {{"access-control-allow-origin": "*"}}]\''.format(token, token))

  user_data = {'role': group_id, 'community_id': community_id, 'user_id': delibrium_user_id }
  output = {'status': 'success', 'data': user_data}

  return json.dumps(output)
$$;

create or replace function delibrium.refresh_token() returns text as $$
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

-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function refresh_token() from public;

alter database delibrium set "app.jwt_secret" to 'sh3d3SeWWQTn85sDZ8ytKmtS36HJtEhJ';

create policy community_admin_users on delibrium.users using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_community on delibrium.community using (delibrium.is_admin(id)) with check (delibrium.is_admin(id));
create policy community_admin_idea_space on delibrium.idea_space using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_topic on delibrium.topic using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_feasible on delibrium.feasible using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea on delibrium.idea using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea_like on delibrium.idea_like using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea_vote on delibrium.idea_vote using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_comment on delibrium.comment using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_comment_vote on delibrium.comment_vote using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_community_class on delibrium.community_class using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_user_group on delibrium.user_group using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_delegation on delibrium.delegation using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));

drop policy user_login on delibrium_secure.user_login ;
create policy user_login on delibrium_secure.user_login using (delibrium.is_admin(community_id) or delibrium.is_owner(delibrium_user_id)) with check (delibrium.is_admin(community_id) or delibrium.is_owner(delibrium_user_id));

DROP FUNCTION communitys(delibrium.users);
CREATE  or replace FUNCTION communitys(delibrium.users) RETURNS table (id bigint, name text)
language plpgsql
 AS $$
  begin
  return query SELECT delibrium.community.id, delibrium.community.name from delibrium.community where delibrium.community.id = $1.community_id;
 end;
$$;

alter table delibrium.users enable row level security;
alter table delibrium.community enable row level security;
alter table delibrium.idea_space enable row level security;
alter table delibrium.topic enable row level security;
alter table delibrium.feasible enable row level security;
alter table delibrium.idea enable row level security;
alter table delibrium.idea_like enable row level security;
alter table delibrium.idea_vote enable row level security;
alter table delibrium.comment enable row level security;
alter table delibrium.comment_vote enable row level security;
alter table delibrium.community_class enable row level security;
alter table delibrium.user_group enable row level security;
alter table delibrium.delegation enable row level security;
alter table delibrium_secure.user_login enable row level security;

create role delibrium_authenticator nologin;
grant delibrium_authenticator to aivuk;
grant usage on schema delibrium to delibrium_authenticator;
grant all on all tables in schema delibrium to delibrium_authenticator;
grant usage, select on all sequences in schema delibrium to delibrium_authenticator;

grant usage on schema delibrium_secure to delibrium_authenticator;
grant all on all tables in schema delibrium_secure to delibrium_authenticator;
grant usage, select on all sequences in schema delibrium_secure to delibrium_authenticator;
grant execute on function delibrium_secure.check_user() to delibrium_authenticator;
grant execute on function delibrium_secure.encrypt_pass() to delibrium_authenticator;
grant execute on function delibrium_secure.user_id(text,text) to delibrium_authenticator;
grant execute on function delibrium.login(text,text) to delibrium_authenticator;
grant execute on function delibrium.logout() to delibrium_authenticator;
grant execute on function delibrium.refresh_token() to delibrium_authenticator;
grant execute on function delibrium.change_password(bigint, text) to delibrium_authenticator;
grant execute on function delibrium.config(bigint, text, text) to delibrium_authenticator;

