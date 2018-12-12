create or replace function aula_secure.change_password(user_id bigint, new_password text)
   returns void
   language plpgsql
as $$
declare
  school_id bigint;
 begin
 raise info 'CHANGE PASS: user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
  if current_setting('request.jwt.claim.user_group') = 'admin' then
    select aula.users.school_id into school_id from aula.users where aula.users.id = user_id;
  else
    school_id := cast(current_setting('request.jwt.claim.school_id') as numeric);
  end if;

   insert into aula_secure.user_login (school_id, aula_user_id, password) values (school_id, user_id, new_password)
    on conflict (aula_user_id) do update set password = new_password;
 end
$$;

create or replace function aula.change_password(user_id bigint, password text)
   returns void
   language plpgsql
as $$
 begin
 raise info 'CHANGE PASS: user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
   perform aula_secure.change_password(user_id, password);
 end
$$;

create or replace function aula.config_update(space_id bigint, key text, value text)
  returns void
  language plpgsql
as $$
  begin
  update aula.school set config = jsonb_set(config, array_append(array[]:: text[], key), to_jsonb(value)) where id = space_id;
  end
$$;

create or replace function aula.config(space_id bigint)
  returns json
  language plpgsql
as $$
declare
  config json;
  begin
    select aula.school.config from aula.school where id = space_id into config;
    return config;
  end
$$;

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

create or replace function aula_secure.check_user()
 returns void
 language plpgsql
as $$
declare
  user_id integer;
  user_role text;
  session_count_claim integer;
  session_count integer;
begin
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
    select aula_secure.user_login.session_count into session_count from aula_secure.user_login where aula_user_id = cast(user_id as numeric);
    if session_count > cast(session_count_claim as numeric) then
      raise exception 'session expired'
        using hint = 'login again', detail = '';
    end if;
  end if;
end
$$;

create or replace function aula.is_owner(user_id bigint)
  returns boolean
  language plpgsql
as $$
begin
  return (cast(current_setting('request.jwt.claim.user_id') as numeric) = user_id);
end
$$;

create or replace function aula.is_admin(school_id bigint)
  returns boolean
  language plpgsql
as $$
declare
  gid aula.group_id;
begin
  raise info 'CHECK IS ADMIN';
  raise info 'user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
  return (current_setting('request.jwt.claim.user_group', true) = 'admin') or (cast(current_setting('request.jwt.claim.school_id', true) as "numeric") = school_id and current_setting('request.jwt.claim.user_group', true) = 'school_admin');
end
$$;

-- Login

create extension if not exists pgcrypto;
create extension if not exists pgjwt;

create or replace function
aula_secure.encrypt_pass() returns trigger
  language plpgsql
  as $$
begin
  if tg_op = 'INSERT' or new.password <> old.password then
    new.password = crypt(new.password, gen_salt('bf'));
  end if;
  return new;
end
$$;

drop trigger if exists encrypt_pass on aula_secure.user_login;
create trigger encrypt_pass
  before insert or update on aula_secure.user_login
  for each row
  execute procedure aula_secure.encrypt_pass();

create or replace function aula_secure.user_id(school_id bigint, username text, password text)
  returns table (uid bigint, sc integer)
  language plpgsql
as $$
  begin
    set "request.jwt.claim.user_group" TO 'admin';

    return query 
      select 
        aula.users.id, 
        aula_secure.user_login.session_count
      from 
        aula.users, 
        aula_secure.user_login 
      where 
        aula.users.user_login_id = aula_secure.user_login.id 
        and aula.users.school_id = user_id.school_id
        and aula_secure.user_login.login = user_id.username  
        and aula_secure.user_login.password = crypt(
          user_id.password, 
          aula_secure.user_login.password
        );
  end;
$$;

CREATE TYPE aula_secure.jwt_token AS (
   token text
);

create language plpython3u;

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

create or replace function aula.refresh_token() returns text as $$
declare
  usr record;
  token text;
begin
    raise info 'TOKEN %', current_setting('request.jwt', true);

    EXECUTE format(
    ' select row_to_json(u.*) as j'
        ' from aula_secure.user_login as u'
        ' where u.aula_user_id = cast($1 as numeric)')
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
revoke all privileges on function aula.refresh_token() from public;


create policy school_admin_users on aula.users using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_school on aula.school using (aula.is_admin(id)) with check (aula.is_admin(id));
create policy school_admin_idea_space on aula.idea_space using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_topic on aula.topic using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_feasible on aula.feasible using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea on aula.idea using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea_like on aula.idea_like using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea_vote on aula.idea_vote using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_comment on aula.comment using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_comment_vote on aula.comment_vote using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_school_class on aula.school_class using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_user_group on aula.user_group using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_delegation on aula.delegation using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
drop policy if exists user_login on aula_secure.user_login ;
create policy user_login on aula_secure.user_login using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy admin_user_listing on aula.user_listing using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));

alter table aula.users enable row level security;
alter table aula.school enable row level security;
alter table aula.idea_space enable row level security;
alter table aula.topic enable row level security;
alter table aula.feasible enable row level security;
alter table aula.idea enable row level security;
alter table aula.idea_like enable row level security;
alter table aula.idea_vote enable row level security;
alter table aula.comment enable row level security;
alter table aula.comment_vote enable row level security;
alter table aula.school_class enable row level security;
alter table aula.user_group enable row level security;
alter table aula.delegation enable row level security;
alter table aula_secure.user_login enable row level security;

create role aula_authenticator nologin;
grant usage on schema aula to aula_authenticator;
grant all on all tables in schema aula to aula_authenticator;
grant usage, select on all sequences in schema aula to aula_authenticator;


grant usage on schema aula_secure                                   to aula_authenticator;
grant all on all tables in schema aula_secure                       to aula_authenticator;
grant usage, select on all sequences in schema aula_secure          to aula_authenticator;

grant execute on function aula_secure.check_user()                  to aula_authenticator;
grant execute on function aula_secure.encrypt_pass()                to aula_authenticator;
grant execute on function aula_secure.user_id(bigint, text, text)   to aula_authenticator;
grant execute on function aula.login(bigint, text, text)            to aula_authenticator;
grant execute on function aula.logout()                             to aula_authenticator;
grant execute on function aula.refresh_token()                      to aula_authenticator;
grant execute on function aula.change_password(bigint, text)        to aula_authenticator;
grant execute on function aula.config(bigint, text, text)           to aula_authenticator;
grant execute on function aula.user_listing()                       to aula_authenticator;



-- Enable public school listing
create policy public_school_listing on aula.school using (true);
revoke select on aula.school from public;
grant select (id, name) on aula.school to public;


-- You need to put the right user in the line below instead of 'aivuk'
grant aula_authenticator to aula;
-- Correct the database and set the JWT secret below
alter database aula set "app.jwt_secret" to 'sh3d3SeWWQTn85sDZ8ytKmtS36HJtEhJ';


