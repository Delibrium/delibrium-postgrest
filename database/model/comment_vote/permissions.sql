alter table aula.comment_vote enable row level security;

-- Comment Vote
drop policy if exists school_select_comment_vote on aula.comment_vote;
create policy school_select_comment_vote on aula.comment_vote for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_comment_vote on aula.comment_vote;
create policy school_create_comment_vote on aula.comment_vote for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_update_comment_vote on aula.comment_vote;
create policy school_update_comment_vote on aula.comment_vote for update using (aula.is_admin(school_id) or (aula.from_school(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));

drop policy if exists school_delete_comment_vote on aula.comment_vote;
create policy school_delete_comment_vote on aula.comment_vote for delete using (aula.is_admin(school_id) or aula.is_owner(created_by));
