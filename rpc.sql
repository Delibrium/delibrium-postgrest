create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;


create or replace function aula.create_school(name text, config jsonb default null)
    returns json
    language plpython3u
as $$
    result = plpy.execute("""
        insert into aula.school ( name, config ) values ( '{name}', '{config}' );
    """.format(
        name=name,
        config=config
    ))

    plpy.info(result)

    school_id = result[0].id

    result2 = plpy.execute("""
        insert into category (school_id, name, description) values ({school_id}, 'Regeln', '');
        insert into category (school_id, name, description) values ({school_id}, 'Ausstattung', '');
        insert into category (school_id, name, description) values ({school_id}, 'Aktivitäten', '');
        insert into category (school_id, name, description) values ({school_id}, 'Unterricht', '');
        insert into category (school_id, name, description) values ({school_id}, 'Zeit', '');
        insert into category (school_id, name, description) values ({school_id}, 'Umgebung', '');
    """.format(school_id))

    return result
$$;