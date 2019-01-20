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

res_school_id = plpy.execute(
    "select current_setting('request.jwt.claim.school_id');"
)
if len(res_school_id) == 0:
    plpy.error('Current user is not associated with a school.', sqlstate='PT401')
school_id = res_school_id[0]['current_setting']

res_calling_user_id = plpy.execute(
    "select current_setting('request.jwt.claim.user_id');"
)
if len(res_calling_user_id) == 0:
    plpy.error('Did not find user associated with this request.', sqlstate='PT401')
calling_user_id = res_calling_user_id[0]['current_setting']

def create_random_password():
    try:
        dict_location = '/usr/share/dict/words'
        with open(dict_location) as f:
            words = f.readlines()
        return ".".join([random.choice(words).strip() for _ in range(2)])
    except FileNotFoundError:
        plpy.warning("""Place a dictionary file in {} to enable
            word-based temp passwords""".format(dict_location))
        return  ''.join(random.choice(
            string.ascii_uppercase + string.ascii_lowercase + string.digits
        ) for _ in range(12))


password = create_random_password()
new_config = json.dumps({ "temp_password": password })

q1 = """insert
    into aula_secure.user_login (school_id, login, password, config )
    values ({}, '{}', '{}', '{}') returning id ;""".format(
        school_id, username, password, new_config
    )
# plpy.info(q1)
res_user_login = plpy.execute(q1)
user_login = res_user_login[0]

q2 = """insert
    into aula.users (
        school_id,
        created_by,
        changed_by,
        user_login_id,
        first_name,
        last_name,
        email
    ) values ( {}, {}, {}, '{}', '{}', '{}', '{}') returning id;
""".format(
    school_id,
    calling_user_id,
    calling_user_id,
    user_login['id'],
    first_name,
    last_name,
    email or ''
)
# plpy.info(q2)
res_user = plpy.execute(q2)
user = res_user[0]

q3 = """insert
    into aula.user_group (school_id, user_id, group_id, idea_space)
    values ( {}, {}, '{}', {});""".format(
        school_id,
        user['id'],
        user_group,
        idea_space or 'null'
    )
# plpy.info(q3)
plpy.execute(q3)

q4 = "update aula_secure.user_login set aula_user_id={} where id={};".format(
        user['id'],
        user_login['id']
    )
# plpy.info(q4)
plpy.execute(q4)
$$;

