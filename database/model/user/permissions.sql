alter table aula.users enable row level security;

drop policy if exists school_admin_users on aula.users;
create policy
  school_admin_users
  on aula.users
  using
    (aula.is_admin(school_id) or aula.from_school(school_id) or aula.is_owner(id))
  with check
    (aula.is_admin(school_id) or aula.is_owner(id));
