-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function aula.refresh_token() from public;

drop policy if exists school_admin_school_class on aula.school_class;
create policy school_admin_school_class on aula.school_class using (aula.is_admin(school_id) or aula.from_school(school_id)) with check (aula.is_admin(school_id));

drop policy if exists school_admin_user_group on aula.user_group;
create policy school_admin_user_group on aula.user_group using (aula.is_admin(school_id) or aula.is_owner(user_id)) with check (aula.is_admin(school_id) or aula.is_owner(user_id));

drop policy if exists school_admin_school on aula.school;
create policy school_admin_school on aula.school using (aula.is_admin(id) or aula.from_school(school_id)) with check (aula.is_admin(id));

drop policy if exists school_admin_idea_space on aula.idea_space;
create policy school_admin_idea_space on aula.idea_space using (aula.is_admin(school_id) or aula.from_school(school_id)) with check (aula.is_admin(school_id));

drop policy if exists school_admin_topic on aula.topic;
create policy school_admin_topic on aula.topic using (aula.is_admin(school_id) or aula.from_school(school_id)) with check (aula.is_admin(school_id));

drop policy if exists school_admin_feasible on aula.feasible;
create policy school_admin_feasible on aula.feasible using (aula.is_admin(school_id) or aula.from_school(school_id)) with check (aula.is_admin(school_id));

-- Idea
drop policy if exists school_select_idea on aula.idea;
create policy school_select_idea on aula.idea for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_idea on aula.idea;
create policy school_create_idea on aula.idea for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_idea on aula.idea;
create policy school_update_idea on aula.idea for update using (aula.is_admin(school_id) or (aula.is_owner(created_by))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_idea on aula.idea;
create policy school_delete_idea on aula.idea for delete using (aula.is_admin(school_id));

-- Users TODO: Create view to restrict columns

drop policy if exists school_admin_users on aula.users;
create policy school_admin_users on aula.users using (aula.is_admin(school_id) or aula.from_school(school_id) or aula.is_owner(id)) with check (aula.is_admin(school_id) or aula.is_owner(id));

-- Idea Like
drop policy if exists school_select_idea_like on aula.idea_like;
create policy school_select_idea_like on aula.idea_like for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_idea_like on aula.idea_like;
drop policy if exists school_create_idea_like on aula.idea_like;
create policy school_create_idea_like on aula.idea_like for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_idea_like on aula.idea_like;
create policy school_update_idea_like on aula.idea_like for update using (aula.is_admin(school_id) or (aula.is_owner(created_by))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_idea_like on aula.idea_like;
create policy school_delete_idea_like on aula.idea_like for delete using (aula.is_admin(school_id) or (aula.is_owner(created_by)));

-- Idea Vote
drop policy if exists school_select_idea_vote on aula.idea_vote;
create policy school_select_idea_vote on aula.idea_vote for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_idea_vote on aula.idea_vote;
create policy school_create_idea_vote on aula.idea_vote for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_idea_vote on aula.idea_vote;
create policy school_update_idea_vote on aula.idea_vote for update using (aula.is_admin(school_id) or (aula.is_owner(created_by))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_idea_vote on aula.idea_vote;
create policy school_delete_idea_vote on aula.idea_vote for delete using (aula.is_admin(school_id) or (aula.is_owner(created_by)));


-- Comment
drop policy if exists school_select_comment on aula.comment;
create policy school_select_comment on aula.comment for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_comment on aula.comment;
create policy school_create_comment on aula.comment for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_comment on aula.comment;
create policy school_update_comment on aula.comment for update using (aula.is_admin(school_id) or (aula.from_school(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_comment on aula.comment;
create policy school_delete_comment on aula.comment for delete using (aula.is_admin(school_id));

-- Comment Vote
drop policy if exists school_select_comment_vote on aula.comment_vote;
create policy school_select_comment_vote on aula.comment_vote for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_comment_vote on aula.comment_vote;
create policy school_create_comment_vote on aula.comment_vote for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_comment_vote on aula.comment_vote;
create policy school_update_comment_vote on aula.comment_vote for update using (aula.is_admin(school_id) or (aula.from_school(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_comment_vote on aula.comment_vote;
create policy school_delete_comment_vote on aula.comment_vote for delete using (aula.is_admin(school_id) or (aula.is_owner(school_id)));


-- Delegation
drop policy if exists school_select_delegation on aula.delegation;
create policy school_select_delegation on aula.delegation for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_create_delegation on aula.delegation;
create policy school_create_delegation on aula.delegation for insert with check (aula.is_admin(school_id) or (aula.from_school(school_id)));
drop policy if exists school_update_delegation on aula.delegation;
create policy school_update_delegation on aula.delegation for update with check (aula.is_admin(school_id) or (aula.is_owner(created_by)));
drop policy if exists school_delete_delegation on aula.delegation;
create policy school_delete_delegation on aula.delegation for delete using (aula.is_admin(school_id));

drop policy if exists user_login on aula_secure.user_login ;
create policy user_login on aula_secure.user_login using (aula.is_admin(school_id) or aula.is_owner(aula_user_id)) with check (aula.is_admin(school_id) or aula.is_owner(aula_user_id));
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
grant execute on function aula.change_password(bigint, text, text)        to aula_authenticator;
grant execute on function aula.user_listing()                       to aula_authenticator;
grant execute on function aula.get_page(bigint,text) to aula_authenticator;
grant execute on function aula.update_page(bigint, text, text) to aula_authenticator;

-- Enable public school listing
drop policy public_school_listing on aula.school;
create policy public_school_listing on aula.school using (true);
revoke select on aula.school from public;
grant select (id, name) on aula.school to public;
