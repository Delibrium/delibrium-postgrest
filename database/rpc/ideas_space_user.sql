create or replace function aula.ideas_space_user(spaceid bigint default null, schoolid bigint default null)
    returns json
    language plpython3u
as $$

import json

plpy.info ('INFO SCHOOL', schoolid, spaceid)

if schoolid is None:
  res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
  if len(res_school_id) == 0:
      plpy.error('Current user is not associated with a school.', sqlstate='PT401')
  school_id = res_school_id[0]['current_setting']
  plpy.info('NOW THE ID IS', school_id)
else:
  school_id = schoolid

if spaceid:
  users_plan = plpy.prepare("""
      select
        id,
        first_name,
        picture
        from aula.users where id in (select distinct user_id from aula.user_group  where school_id = $1 and idea_space = $2) """, ['bigint', 'bigint'])
  users = plpy.execute(users_plan, [school_id, spaceid])
else:
  users_plan = plpy.prepare("""
      select
        id,
        first_name,
        picture
        from aula.users where id in (select distinct user_id from aula.user_group  where school_id = $1) """, ['bigint'])
  users = plpy.execute(users_plan, [school_id])

return json.dumps([user for user in users])
$$;

grant execute on function aula.ideas_space_user(bigint, bigint) to aula_authenticator;
