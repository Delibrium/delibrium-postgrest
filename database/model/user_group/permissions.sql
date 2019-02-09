alter table aula.user_group enable row level security;

drop policy if exists school_admin_user_group on aula.user_group;
create policy
  school_admin_user_group
  on aula.user_group
  using
  (aula.is_admin(school_id) or aula.is_owner(user_id))
  with check (aula.is_admin(school_id) or aula.is_owner(user_id));
