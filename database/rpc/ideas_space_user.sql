create or replace function aula.ideas_space_user(spaceid bigint default null, schoolid bigint default null)
    returns json
    language plpython3u
as $$

import json

if schoolid is None:
  res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
  if len(res_school_id) == 0:
      plpy.error('Current user is not associated with a school.', sqlstate='PT401')
  school_id = res_school_id[0]['current_setting']
else:
  school_id = schoolid

if spaceid:
  users_plan = plpy.prepare("""
      select
        aula.users.id,
        aula_secure.user_login.login,
        aula.users.picture
        from aula.users join aula_secure.user_login on aula_secure.user_login.aula_user_id = aula.users.id
        where aula.users.id in (select distinct user_id from aula.user_group  where school_id = $1 and idea_space = $2 and aula.users.config->'deleted' is null) """, ['bigint', 'bigint'])
  users = plpy.execute(users_plan, [school_id, spaceid])
else:
  users_plan = plpy.prepare("""
      select
        aula.users.id,
        aula_secure.user_login.login,
        aula.users.picture
        from aula.users join aula_secure.user_login on aula_secure.user_login.aula_user_id = aula.users.id
        where aula.users.id in (select distinct user_id from aula.user_group  where school_id = $1 and aula.users.config->'deleted' is null) """, ['bigint', 'bigint'])
  users = plpy.execute(users_plan, [school_id])

return json.dumps([user for user in users])
$$;

grant execute on function aula.ideas_space_user(bigint, bigint) to aula_authenticator;
