create extension if not exists plpython3u CASCADE;
create or replace language plpython3u;


create or replace function aula.create_school(name text, config jsonb default null)
    returns void
    language plpython3u
as $$
    import os
    import base64

    result = plpy.execute("""
        insert into aula.school ( name, config ) values ( '{name}', '{config}' ) returning id;
    """.format(
        name=name,
        config=config
    ))

    plpy.info('Created school as', result[0])

    school_id = result[0]['id']

    default_description = "Beschreibung der Kategorie"
    default_categories = {
        'Regeln': default_description,
        'Ausstattung': default_description,
        'Aktivitäten': default_description,
        'Unterricht': default_description,
        'Zeit': default_description,
        'Umgebung': default_description,
        'Sonstiges': default_description
    }

    for cat_name, cat_description in default_categories.items():
        fname = '/ressources/category_icons/Kategorien_{}-blau.png'.format(cat_name)
        plpy.info('Opening icon file from', os.path.abspath(fname))
        with open(fname, 'rb') as f:
            cat_icon = base64.b64encode(f.read())
            plpy.info("File contents:", cat_icon)
            q = plpy.prepare("""insert 
                into aula.category (school_id, name, description, icon) 
                values ($1, $2, $3, $4);
            """, ["bigint", "text", "text", "bytea"])
            plpy.execute(q, [school_id, cat_name, cat_description, cat_icon])
    return
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
