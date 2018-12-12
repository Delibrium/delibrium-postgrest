create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;

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

create or replace function aula.update_user(
    id bigint,
    first_name text, 
    last_name text, 
    username text,
    email text default null
) returns void language plpython3u
as $$
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

    q2 = "update aula_secure.user_login set login='{}' where id='{}';".format(
        username, login_id
    )
    plpy.execute(q2)
$$;

create or replace function aula.user_listing()
    returns json
    language plpython3u
as $$
    import json
    
    res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
    if len(res_school_id) == 0:
        plpy.error('Current user is not associated with a school.', sqlstate='PT401')

    school_id = res_school_id[0]['current_setting']

    rv = plpy.execute("""
        select
            us.*,
            ul.config,
            ul.login,
            array_agg(row(
                ug.group_id,
                ug.idea_space,
                sp.title
            )) as groups
        from
            aula.users as us
            join
                aula_secure.user_login as ul
                on ul.id=us.user_login_id
            left join 
                aula.user_group as ug 
                on ug.user_id=us.id
            left join 
                aula.idea_space as sp 
                on sp.id=ug.idea_space
        where us.school_id={}
        group by (us.id, ul.login, ul.config);
    """.format(school_id))

    return json.dumps([user for user in rv])
$$;

create or replace function aula.quorum_info(school_id bigint, space_id bigint default null)
  returns json
  language plpython3u
as $$
    import json
    import math

    result = plpy.execute("""
        select config 
        from aula.school 
        where id = {};
    """.format(school_id))

    if len(result) == 0:
        plpy.error('School not found', sqlstate='PT404')
        return

    config = json.loads(result[0]['config'])
    
    if 'classQuorum' not in config:
        config = {
            'schoolQuorum': 30,
            'classQuorum': 30
        }

    if space_id is None:
        usercount = plpy.execute("""
            select count(distinct user_id) 
            from aula.user_group 
            where school_id={};
        """.format(school_id))[0]['count']
        config['totalVoters'] = usercount
        quorum_threshold = 0.01 * int(config['schoolQuorum'])
    else:
        usercount = plpy.execute("""
            select count(distinct user_id) 
            from aula.user_group 
            where group_id='student'
            and idea_space={};
        """.format(space_id))[0]['count']
        config['totalVoters'] = usercount
        quorum_threshold = 0.01 * int(config['classQuorum'])

    config['totalVoters'] = usercount
    config['requiredVoteCount'] = max(1, math.ceil(usercount * quorum_threshold))

    return json.dumps(config)
$$;

create or replace function aula.school_listing()
  returns json
  language plpython3u
as $$
    import json
    result = plpy.execute("select id, name from aula.school;")
    rv = [{
        "text": elem['name'],
        "value": elem['id']
    } for elem in result]
    return json.dumps(rv)
$$;