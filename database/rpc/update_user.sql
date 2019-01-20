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


