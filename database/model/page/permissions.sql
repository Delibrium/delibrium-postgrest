alter table aula.page enable row level security;

drop policy if exists page_admin on aula.page;
create policy
  page_admin
  on aula.page
  using
    ((public = true) or aula.is_admin(id) or aula.from_school(id))
  with check
    (aula.is_admin(id));
