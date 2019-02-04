create or replace function aula.delete_space(school_id bigint, space_id bigint)
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
      #  delete roles
      #  plpy.execute('delete from aula.user_group where idea_space = {}'.format(school_id))
      #  delete comment
      ideas = plpy.execute('select id from aula.idea where school_id = {} and idea_space = {}'.format(school_id, space_id))
      for idea in ideas:
        # Delete comments
        comments = plpy.execute('select id from aula.comment where parent_idea = {}'.format(idea['id']))
        for comment in comments:
          plpy.execute('delete from aula.comment_vote where comment = {}'.format(comment['id']))
          plpy.info('delete from aula.comment_vote where comment = {}'.format(comment['id']))
        plpy.execute('delete from aula.comment where parent_idea = {}'.format(idea['id']))
        # Delete idea votes
        plpy.execute('delete from aula.idea_vote where idea = {}'.format(idea['id']))
        # Delete idea like
        plpy.execute('delete from aula.idea_like where idea = {}'.format(idea['id']))
        # Delete idea feasibility
        plpy.execute('delete from aula.feasible where idea = {}'.format(idea['id']))
        # Delete idea
        plpy.execute('delete from aula.idea where id = {}'.format(idea['id']))
      plpy.info('delete from aula.idea where idea_space = {}'.format(space_id))

      # Delete topics
      topics = plpy.execute('select id from aula.topic where idea_space = {}'.format(space_id))
      for topic in topics:
        plpy.execute('delete from aula.delegation where context_topic = {}'.format(topic['id']))
      plpy.execute('delete from aula.topic where idea_space = {}'.format(space_id))
      # Delete Idea Space
      plpy.execute('delete from aula.user_group where idea_space = {}'.format(space_id))
      plpy.execute('delete from aula.idea_space where id = {}'.format(space_id))

    return json.dumps([])
$$;
