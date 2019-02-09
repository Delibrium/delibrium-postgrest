alter table aula.comment enable row level security;

-- Comment
drop policy if exists school_select_comment on aula.comment;
create policy school_select_comment on aula.comment for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_comment on aula.comment;
create policy school_create_comment on aula.comment for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_update_comment on aula.comment;
create policy school_update_comment on aula.comment for update using
(aula.is_admin(school_id) or (aula.from_school(school_id)) or aula.has_role_comment(cast('moderator' as text), parent_idea, school_id))
  with check
  (aula.is_admin(school_id) or (aula.is_owner(created_by)) or aula.has_role_comment('moderator', parent_idea, school_id));

drop policy if exists school_delete_comment on aula.comment;
create policy school_delete_comment on aula.comment for delete using (aula.is_admin(school_id));


