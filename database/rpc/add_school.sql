create or replace function aula.add_school (
    school_name text
  ) returns jsonb language plpython3u
as $$
import json
import random
import string

# default community config

default_community_config = {
  'classQuorum': 30,
  'schoolQuorum': 30,
  'mainSpaceName': 'Schule',
  'phaseVoting': 1,
  'phaseWorking': 1,
  'phases': ['edit_topics', 'feasibility', 'vote', 'finished']
}

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
is_admin = plpy.execute(is_admin_plan, [1])
if not is_admin[0]['is_admin']:
  plpy.error('User must be admin to create users')

q0plan = plpy.prepare("""select id from aula.school where name = $1""", ["text"])
q0 = plpy.execute(q0plan, [school_name])
if len(q0) > 0:
  plpy.error('School name already exist', sqlstate=23505)

q1plan = plpy.prepare("""
  insert
    into aula.school (
        created_by,
        name,
        config
    ) values ( $1, $2, $3 ) returning id;
    """, ["bigint", "text", "jsonb"])

q1 = plpy.execute(q1plan, [ calling_user_id,
                            school_name, json.dumps(default_community_config)])

new_school_id = q1[0]['id']

def make_random_pass(size = 6, with_upper = False):
    chars = string.ascii_lowercase + string.digits
    if with_upper:
      chars += string.ascii_uppercase
    return  ''.join(random.choice(chars) for _ in range(size))


# Create user on not exposed table
random_password = make_random_pass()
q2plan = plpy.prepare("""insert into aula_secure.user_login (school_id, login, password) values ( $1, 'admin', $2) returning id;""", ["bigint", "text"])
q2 = plpy.execute(q2plan, [new_school_id, random_password])
user_login_id = q2[0]['id']

# Create user on API exposed table
q3plan =  plpy.prepare("""insert into aula.users (school_id, user_login_id, first_name, last_name, changed_by, username) values ($1, $2, 'Admin', $3, $4, 'admin') returning id;""", [ "bigint", "bigint", "text", "bigint" ])
q3 = plpy.execute(q3plan, [new_school_id, user_login_id, school_name, calling_user_id])
user_id = q3[0]['id']

# Configure user as community admin
q4plan =  plpy.prepare("""insert into aula.user_group (school_id, user_id, group_id) values($1, $2, 'school_admin');""", ["bigint", "bigint"])
q4 = plpy.execute(q4plan, [new_school_id, user_id])

# Create default categories
q5plan = plpy.prepare("""insert into aula.category (school_id, name, description, image, position, def) select $1, name, description, image, position,def from aula.category where school_id = 1""", [ "bigint" ])
q5 = plpy.execute(q5plan, [new_school_id])

return json.dumps({'password': random_password})

$$;

grant execute on function aula.add_school (text) to aula_authenticator;

