alter table aula.idea enable row level security;

-- Idea
drop policy if exists school_select_idea on aula.idea;
create policy school_select_idea on aula.idea for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_idea on aula.idea;
create policy school_create_idea on aula.idea for insert with check (
  -- If user is admin, or admin for the school
  aula.is_admin(school_id) or
  (
  -- of if user is from the school and wants to create an idea on school level
    (aula.from_school(school_id) and idea_space is null and
      created_by = request.user_id())
  -- of if user wants to create an idea on ideas space the he belongs as student
    or
    ((aula.from_space('student', idea_space)) and
      (created_by = request.user_id()))
    or
    (aula.has_role('moderator', null))
    or
    (aula.from_space('moderator', idea_space))
  )
);

drop policy if exists school_update_idea on aula.idea;
create policy school_update_idea on aula.idea for update using (aula.is_admin(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id)));

drop policy if exists school_delete_idea on aula.idea;
create policy school_delete_idea on aula.idea for delete using (aula.is_admin(school_id));

