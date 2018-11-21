create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;

create or replace function aula.add_user (
    first_name text, 
    last_name text, 
    username text,
    password text,
    email text default null, 
    group_id user_group default 'student',
    bigint idea_space default null
  ) returns void language plpgsql
as $$
declare
    school_id bigint;
    calling_user_id bigint;
    user_login_id bigint;
    users_id bigint;
begin
    school_id := cast(current_setting('request.jwt.claim.school_id') as numeric);
    raise info 'school id', school_id;

    calling_user_id = := cast(current_setting('request.jwt.claim.user_id') as numeric);
    raise info 'calling user id', calling_user_id;

    user_login_id = insert into aula_secure.user_login (
            school_id, login, password, config
        ) values (
            school_id, 
            add_user.username, 
            add_user.password, 
            replace ('{"temp_password": "%"}', '%', add_user.password)
        ) returning id;
    raise info 'user_login_id', user_login_id;

    users_id = insert into aula.users (
            school_id, 
            created_by, 
            changed_by, 
            user_login_id, 
            first_name, 
            last_name, 
            email
        ) values (
            school_id, 
            calling_user_id, 
            calling_user_id, 
            user_login_id, 
            add_user.first_name, 
            add_user.last_name, 
            add_user.email
        ) returning id;

    insert 
        into aula.user_group (school_id, user_id, group_id, idea_space)
        values (
            school_id, users_id, add_user.user_group, add_user.idea_space
        );

end;
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