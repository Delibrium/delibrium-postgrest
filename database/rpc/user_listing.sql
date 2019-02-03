create or replace function aula.ideas_space_user(space_id bigint)
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
          id,
          first_name,
          picture
          from aula.users where id in (select distinct user_id from aula.user_group  where school_id = {} and idea_space = {}) """.format(school_id, space_id))

    return json.dumps([user for user in rv])
$$;
