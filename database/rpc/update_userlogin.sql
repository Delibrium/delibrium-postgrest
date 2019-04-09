create or replace function aula.update_userlogin(
    user_id bigint,
    username text
) returns json language plpython3u
as $$

import json

# Get school id from JWT
res_school_id = plpy.execute(
    "select current_setting('request.jwt.claim.school_id');"
)
if len(res_school_id) == 0:
    plpy.error('Current user is not associated with a school.', sqlstate='PT401')
school_id = res_school_id[0]['current_setting']

# Get User id
res_calling_user_id = plpy.execute(
    "select current_setting('request.jwt.claim.user_id');"
  )
if len(res_calling_user_id) == 0:
    plpy.error('Did not find user associated with this request.', sqlstate='PT401')
calling_user_id = res_calling_user_id[0]['current_setting']

# Check if user is admin
is_admin_plan = plpy.prepare(
    "select aula.is_admin($1);", ["bigint"]
  )
is_admin = plpy.execute(is_admin_plan, [school_id])
if not is_admin[0]['is_admin']:
  plpy.error('User must be admin to create users')

q = plpy.prepare("""select id from aula.users where username = $1 and school_id = $2;""", ["text", "bigint"])
res = plpy.execute(q, [username, school_id])

if len(res) > 0:
  plpy.error(detail='Username exists', sqlstate='PT500')
else:
  q = plpy.prepare("""update aula.users set username = $1 where school_id = $2 and id = $3;""", ["text", "bigint", "bigint"])
  res = plpy.execute(q, [username, school_id, user_id])
  return json.dumps({'status': 'username updated'})

$$;
