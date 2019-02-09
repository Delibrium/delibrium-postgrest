alter table aula.category enable row level security;

drop policy if exists school_admin_category on aula.category;
create policy
  school_admin_category
  on aula.category
  using
    (aula.is_admin(school_id) or aula.from_school(school_id))
  with check
    (aula.is_admin(school_id));


