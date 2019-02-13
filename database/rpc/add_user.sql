create or replace function aula.add_user (
    first_name text,
    last_name text,
    username text,
    email text default null,
    user_group aula.group_id default 'student',
    idea_space bigint default null
  ) returns void language plpython3u
as $$
import json
import random
import string

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
  plpy.info(is_admin)
  plpy.error('User must be admin to create users')

def create_random_password(with_dict = False):
    def random_without_dict(size = 6, with_upper = False):
        chars = string.ascii_lowercase + string.digits
        if with_upper:
          chars += string.ascii_uppercase
        return  ''.join(random.choice(chars) for _ in range(size))

    if with_dict:
      try:
          dict_location = '/usr/share/dict/words'
          with open(dict_location) as f:
              words = f.readlines()
          return ".".join([random.choice(words).strip() for _ in range(2)])
      except FileNotFoundError:
          plpy.warning("""Place a dictionary file in {} to enable
              word-based temp passwords""".format(dict_location))
          return random_without_dict()
    else:
      return random_without_dict()

password = create_random_password()
new_config = json.dumps({ "temp_password": password })

q1plan = plpy.prepare("""insert
    into aula_secure.user_login (school_id, login, password, config )
    values ($1, $2, $3, $4) returning id ;""", ["bigint", "text", "text", "jsonb"])
q1 = plpy.execute(q1plan, [school_id, username, password, new_config])
plpy.info(q1)
user_login = q1[0]

q2plan = plpy.prepare("""insert
    into aula.users (
        school_id,
        created_by,
        changed_by,
        user_login_id,
        first_name,
        last_name,
        email
    ) values ( $1, $2, $3, $4, $5, $6, $7) returning id;
    """, ["bigint", "bigint", "bigint", "bigint", "text", "text", "text"])
q2 = plpy.execute(q2plan, [ school_id,
                            calling_user_id,
                            calling_user_id,
                            user_login['id'],
                            first_name,
                            last_name,
                            email or ''])
plpy.info(q2)
user = q2[0]

q3plan = plpy.prepare("""insert
    into aula.user_group (school_id, user_id, group_id, idea_space)
    values ( $1, $2, $3, $4);""", ["bigint", "bigint", "aula.group_id", "bigint"])
q3 = plpy.execute(q3plan, [ school_id,
                            user['id'],
                            user_group,
                            idea_space or None])

plpy.info(q3)

q4plan = plpy.prepare("update aula_secure.user_login set aula_user_id= $1 where id= $2;", ["bigint", "bigint"])
q4 = plpy.execute(q4plan, [user['id'], user_login['id']])
plpy.info(q4)
$$;

grant execute on function aula.add_user (text, text, text, text, aula.group_id, bigint) to aula_authenticator;

