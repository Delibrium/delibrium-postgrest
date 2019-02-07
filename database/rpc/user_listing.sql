create or replace function aula.user_listing(schoolid bigint default null)
    returns json
    language plpython3u
as $$
    import json

    if not schoolid:
      res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
      if len(res_school_id) == 0:
          plpy.error('Current user is not associated with a school.', sqlstate='PT401')

      school_id = res_school_id[0]['current_setting']
    else:
      school_id = schoolid

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
