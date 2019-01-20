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
