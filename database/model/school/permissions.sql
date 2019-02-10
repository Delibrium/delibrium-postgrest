alter table aula.school enable row level security;

drop policy if exists school_admin_school on aula.school;
create policy
  school_admin_school
  on aula.school
  using
    (aula.is_admin(id) or aula.from_school(id))
  with check
    (aula.is_admin(id));
