create or replace function aula.update_user(
    id bigint,
    first_name text,
    last_name text,
    email text default null
) returns void language plpython3u
as $$

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

q = """update
aula.users set
    first_name='{}',
    last_name='{}',
    email='{}',
    changed_by='{}',
    changed_at=now()
where
    id='{}'
returning user_login_id;""".format(
    first_name,
    last_name,
    email or '',
    calling_user_id,
    id
)
res = plpy.execute(q)
login_id = res[0]['user_login_id']

$$;

