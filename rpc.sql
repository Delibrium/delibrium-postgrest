create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;

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