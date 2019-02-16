alter table aula.idea_vote enable row level security;

-- Idea Vote
drop policy if exists school_select_idea_vote on aula.idea_vote;
create policy school_select_idea_vote on aula.idea_vote for
  select
  using (aula.is_admin(school_id) or aula.from_school(school_id));

drop policy if exists school_create_idea_vote on aula.idea_vote;
create policy school_create_idea_vote on aula.idea_vote for
  insert
  with check
    (aula.is_admin(school_id)
      or aula.from_school(school_id)
      or delegation.is_delegated(user_id, request.user_id(), idea)
      or user_id = request.user_id());

drop policy if exists school_update_idea_vote on aula.idea_vote;
create policy school_update_idea_vote on aula.idea_vote for
  update
  using
  (aula.is_admin(school_id)
    or aula.is_moderator(user_id)
    or aula.is_owner(created_by)
    or delegation.is_delegated(user_id, request.user_id(), idea))
  with check
  (aula.is_admin(school_id)
    or aula.is_owner(created_by)
    or delegation.is_delegated(user_id, request.user_id(), idea));

drop policy if exists school_delete_idea_vote on aula.idea_vote;
create policy school_delete_idea_vote on aula.idea_vote for
  delete
  using
  (aula.is_admin(school_id)
    or (user_id = request.user_id())
    or aula.is_owner(created_by)
    or delegation.is_delegated(user_id, request.user_id(), idea));
