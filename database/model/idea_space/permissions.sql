alter table aula.idea_space enable row level security;

drop policy if exists school_admin_idea_space on aula.idea_space;
create policy
  school_admin_idea_space
  on aula.idea_space
  using
    (aula.is_admin(school_id) or aula.from_school(school_id))
  with check
    (aula.is_admin(school_id));


