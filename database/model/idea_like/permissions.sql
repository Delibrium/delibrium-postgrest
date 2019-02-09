alter table aula.idea_like enable row level security;

-- Idea Like
drop policy if exists school_select_idea_like on aula.idea_like;
create policy school_select_idea_like on aula.idea_like for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_idea_like on aula.idea_like;
create policy school_create_idea_like on aula.idea_like for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_update_idea_like on aula.idea_like;
create policy school_update_idea_like on aula.idea_like for update using (aula.is_admin(school_id) or (aula.is_owner(created_by))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));

drop policy if exists school_delete_idea_like on aula.idea_like;
create policy school_delete_idea_like on aula.idea_like for delete using (aula.is_admin(school_id) or (aula.is_owner(created_by)));


