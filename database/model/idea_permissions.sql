-- Idea
drop policy if exists school_select_idea on aula.idea;
create policy school_select_idea on aula.idea for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_idea on aula.idea;
create policy school_create_idea on aula.idea for insert with check (
  aula.is_admin(school_id) or
  (
    ((aula.from_school(school_id) and idea_space is null) and
      (created_by = request.user_id()))
    or
    ((aula.from_space('student', idea_space)) and
      (created_by = request.user_id()))
  )
);

drop policy if exists school_update_idea on aula.idea;
create policy school_update_idea on aula.idea for update using (aula.is_admin(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id)));

drop policy if exists school_delete_idea on aula.idea;
create policy school_delete_idea on aula.idea for delete using (aula.is_admin(school_id));

