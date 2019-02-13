create or replace function aula.vote(school_id bigint, topic_id bigint, idea_id bigint, user_id bigint, vote_value aula.idea_vote_value)
  returns jsonb
  language plpython3u
  set search_path = public, aula
as $$
  import json

  get_voters_ids_plan = plpy.prepare("""
      with recursive ids as
        (select from_user from aula.delegation
          where to_user = $1 and context_topic = $2
         union
         select d.from_user from aula.delegation d
        inner join ids i on
          d.to_user = i.from_user and
          d.to_user != $1
        ) select from_user from ids""", ['bigint', 'bigint'])

  voters_ids = plpy.execute(get_voters_ids_plan, [user_id, topic_id])

  vote_plan = plpy.prepare("""
    insert into aula.idea_vote (school_id, idea, created_by, val, user_id)
    values ($1, $2, $3, $4, $5)
    on conflict (idea, user_id)
    do update set val = $4
    """, ['bigint', 'bigint', 'bigint', 'aula.idea_vote_value', 'bigint'])
  for id in voters_ids:
    plpy.info('VOTE => ', [school_id, idea_id, user_id, vote_value, id['from_user']])
    plpy.execute(vote_plan, [school_id, idea_id, user_id, vote_value, id['from_user']])


  plpy.info('VOTE => ', [school_id, idea_id, user_id, vote_value, user_id])
  plpy.execute(vote_plan, [school_id, idea_id, user_id, vote_value, user_id])

  return json.dumps({'status': 'vote_registered'})

$$;

grant execute on function aula.vote(bigint, bigint, bigint, bigint, aula.idea_vote_value) to aula_authenticator;
