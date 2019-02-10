-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function aula.refresh_token() from public;

drop policy if exists user_login on aula_secure.user_login ;
create policy user_login on aula_secure.user_login using (aula.is_admin(school_id) or aula.is_owner(aula_user_id)) with check (aula.is_admin(school_id) or aula.is_owner(aula_user_id));

alter table aula_secure.user_login enable row level security;

grant usage on schema aula to aula_authenticator;
grant all on all tables in schema aula to aula_authenticator;
grant usage, select on all sequences in schema aula to aula_authenticator;

grant usage on schema aula_secure                                   to aula_authenticator;
grant all on all tables in schema aula_secure                       to aula_authenticator;
grant usage, select on all sequences in schema aula_secure          to aula_authenticator;

grant execute on function aula_secure.check_user()                  to aula_authenticator;
grant execute on function aula_secure.encrypt_pass()                to aula_authenticator;
grant execute on function aula_secure.user_id(bigint, text, text)   to aula_authenticator;
grant execute on function aula.login(bigint, text, text)            to aula_authenticator;
grant execute on function aula.logout()                             to aula_authenticator;
grant execute on function aula.refresh_token()                      to aula_authenticator;
grant execute on function aula.change_password(bigint, text, text)        to aula_authenticator;
grant execute on function aula.user_listing()                       to aula_authenticator;
grant execute on function aula.get_page(bigint,text) to aula_authenticator;
grant execute on function aula.update_page(bigint, text, text) to aula_authenticator;
grant execute on function aula.ideas_space_user(bigint) to aula_authenticator;
grant execute on function aula.has_role_comment(aula.group_id, bigint, bigint) to aula_authenticator;
