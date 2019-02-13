alter table aula_secure.user_login enable row level security;

drop policy if exists user_login on aula_secure.user_login ;
create policy user_login on aula_secure.user_login
  using
    (aula.is_admin(school_id) or aula.is_owner(aula_user_id))
  with check
    (aula.is_admin(school_id) or aula.is_owner(aula_user_id));

