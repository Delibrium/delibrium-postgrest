create or replace function aula.delete_idea(school_id bigint, idea_id bigint)
    returns json
    language plpython3u
as $$
    import json

    res_school_id = plpy.execute("select current_setting('request.jwt.claim.school_id');")
    if len(res_school_id) == 0:
        plpy.error('Current user is not associated with a school.', sqlstate='PT401')

    school_id = res_school_id[0]['current_setting']

    res_is_admin = plpy.execute("select aula.is_admin({});".format(school_id))

    is_admin = res_is_admin[0]['is_admin']
    if is_admin:
      comments = plpy.execute('select id from aula.comment where school_id = {} and parent_idea = {}'.format(school_id, idea_id))
      for comment in comments:
        # Delete comments
        plpy.execute('delete from aula.comment_vote where comment = {}'.format(comment['id']))
        plpy.execute('delete from aula.comment where parent_idea = {}'.format(idea_id))
      # Delete idea votes
      plpy.execute('delete from aula.idea_vote where idea = {}'.format(idea_id))
      # Delete idea like
      plpy.execute('delete from aula.idea_like where idea = {}'.format(idea_id))
      # Delete idea feasibility
      plpy.execute('delete from aula.feasible where idea = {}'.format(idea_id))
      # Delete idea
      plpy.execute('delete from aula.idea where id = {}'.format(idea_id))

    return json.dumps([])
$$;

grant execute on function aula.delete_idea (bigint, bigint) to aula_authenticator;
