create or replace function aula.school_listing()
  returns json
  language plpython3u
as $$
    import json

    plpy.execute('set "request.jwt.claim.user_group" TO \'admin\'')

    result = plpy.execute("select id, name from aula.school;")
    rv = [{
        "text": elem['name'],
        "value": elem['id']
    } for elem in result]

    plpy.execute('set "request.jwt.claim.user_group" TO \'\'')

    return json.dumps(rv)
$$;
