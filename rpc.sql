create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;

create or replace function aula.add_user (
    first_name text, 
    last_name text, 
    username text,
    password text,
    email text default null, 
    user_group aula.group_id default 'student',
    idea_space bigint default null
  ) returns void language plpython3u
as $$
import json

res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
if len(res_school_id) == 0:
    plpy.error('Current user is not associated with a school.', sqlstate='PT401')

school_id = res_school_id[0]['current_setting']

res_calling_user_id = plpy.execute("""select current_setting('request.jwt.claim.user_id');""")
if len(res_calling_user_id) == 0:
    plpy.error('Did not find user associated with this request.', sqlstate='PT401')

calling_user_id = res_calling_user_id[0]['current_setting']

new_config = json.dumps({ "temp_password": password })
q1 = """insert 
    into aula_secure.user_login (school_id, login, password, config ) 
    values ({}, '{}', '{}', '{}') returning id ;""".format(
        school_id, username, password, new_config
    )
res_user_login = plpy.execute(q1)
user_login = res_user_login[0]

q2 = """insert
    into aula.users ( 
        school_id, created_by, changed_by, user_login_id, first_name, last_name, email
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
plpy.execute(q3)
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

    plpy.info("""
        select 
            us.*, 
            ul.config, 
            ul.login 
        from 
            aula.users as us, 
            aula_secure.user_login as ul 
        where 
            us.user_login_id=ul.id 
            and us.school_id='{}';
    """.format(school_id))

    rv = plpy.execute("""
        select 
            us.*, 
            ul.config, 
            ul.login 
        from 
            aula.users as us, 
            aula_secure.user_login as ul 
        where 
            us.user_login_id=ul.id 
            and us.school_id={};
    """.format(school_id))

    return json.dumps([user for user in rv])
$$;

create or replace function aula.quorum_info(school_id bigint, space_id bigint default null)
  returns json
  language plpython3u
as $$
    import json

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
    config['requiredVoteCount'] = usercount * quorum_threshold

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