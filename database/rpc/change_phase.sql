create or replace function aula.change_phase(topic bigint, phase text)
    returns json
    language plpython3u
as $$
    import json
    rv = plpy.execute("""
        update aula.topic
        set
            phase='{phase}',
            config=jsonb_set(config, '{{{phase}_started}}', to_json(now())::jsonb, true)
        where id={topic_id}
        returning config;
    """.format(phase=phase, topic_id=topic))
    return rv[0]['config'] if len(rv) > 0 else '{}'
$$;

grant execute on function aula.change_phase(bigint, text) to aula_authenticator;
