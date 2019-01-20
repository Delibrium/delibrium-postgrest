-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function aula.refresh_token() from public;

create policy school_admin_users on aula.users using (aula.is_admin(school_id) or aula.is_owner(id)) with check (aula.is_admin(school_id) or aula.is_owner(id));
create policy school_admin_school on aula.school using (aula.is_admin(id)) with check (aula.is_admin(id));
create policy school_admin_idea_space on aula.idea_space using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_topic on aula.topic using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_feasible on aula.feasible using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea on aula.idea using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea_like on aula.idea_like using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_idea_vote on aula.idea_vote using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_comment on aula.comment using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_comment_vote on aula.comment_vote using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_school_class on aula.school_class using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
create policy school_admin_user_group on aula.user_group using (aula.is_admin(school_id) or aula.is_owner(user_id)) with check (aula.is_admin(school_id) or aula.is_owner(user_id));
create policy school_admin_delegation on aula.delegation using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
drop policy if exists user_login on aula_secure.user_login ;
create policy user_login on aula_secure.user_login using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));
-- create policy admin_user_listing on aula.user_listing using (aula.is_admin(school_id)) with check (aula.is_admin(school_id));

alter table aula.users enable row level security;
alter table aula.school enable row level security;
alter table aula.idea_space enable row level security;
alter table aula.topic enable row level security;
alter table aula.feasible enable row level security;
alter table aula.idea enable row level security;
alter table aula.idea_like enable row level security;
alter table aula.idea_vote enable row level security;
alter table aula.comment enable row level security;
alter table aula.comment_vote enable row level security;
alter table aula.school_class enable row level security;
alter table aula.user_group enable row level security;
alter table aula.delegation enable row level security;
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
grant execute on function aula.change_password(bigint, text)        to aula_authenticator;
grant execute on function aula.user_listing()                       to aula_authenticator;

-- Enable public school listing
create policy public_school_listing on aula.school using (true);
revoke select on aula.school from public;
grant select (id, name) on aula.school to public;
