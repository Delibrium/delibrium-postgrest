revoke all privileges on function refresh_token() from public;

alter database delibrium set "app.jwt_secret" to 'sh3d3SeWWQTn85sDZ8ytKmtS36HJtEhJ';

create policy community_admin_users on delibrium.users using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_community on delibrium.community using (delibrium.is_admin(id)) with check (delibrium.is_admin(id));
create policy community_admin_idea_space on delibrium.idea_space using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_topic on delibrium.topic using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_feasible on delibrium.feasible using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea on delibrium.idea using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea_like on delibrium.idea_like using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_idea_vote on delibrium.idea_vote using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_comment on delibrium.comment using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_comment_vote on delibrium.comment_vote using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_community_class on delibrium.community_class using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_user_group on delibrium.user_group using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));
create policy community_admin_delegation on delibrium.delegation using (delibrium.is_admin(community_id)) with check (delibrium.is_admin(community_id));

drop policy user_login on delibrium_secure.user_login ;
create policy user_login on delibrium_secure.user_login using (delibrium.is_admin(community_id) or delibrium.is_owner(delibrium_user_id)) with check (delibrium.is_admin(community_id) or delibrium.is_owner(delibrium_user_id));

alter table delibrium.users enable row level security;
alter table delibrium.community enable row level security;
alter table delibrium.idea_space enable row level security;
alter table delibrium.topic enable row level security;
alter table delibrium.feasible enable row level security;
alter table delibrium.idea enable row level security;
alter table delibrium.idea_like enable row level security;
alter table delibrium.idea_vote enable row level security;
alter table delibrium.comment enable row level security;
alter table delibrium.comment_vote enable row level security;
alter table delibrium.community_class enable row level security;
alter table delibrium.user_group enable row level security;
alter table delibrium.delegation enable row level security;
alter table delibrium_secure.user_login enable row level security;

create role delibrium_authenticator nologin;
grant delibrium_authenticator to aivuk;
grant usage on schema delibrium to delibrium_authenticator;
grant all on all tables in schema delibrium to delibrium_authenticator;
grant usage, select on all sequences in schema delibrium to delibrium_authenticator;

grant usage on schema delibrium_secure to delibrium_authenticator;
grant all on all tables in schema delibrium_secure to delibrium_authenticator;
grant usage, select on all sequences in schema delibrium_secure to delibrium_authenticator;
grant execute on function delibrium_secure.check_user() to delibrium_authenticator;
grant execute on function delibrium_secure.encrypt_pass() to delibrium_authenticator;
grant execute on function delibrium_secure.user_id(text,text) to delibrium_authenticator;
grant execute on function delibrium.login(text,text) to delibrium_authenticator;
grant execute on function delibrium.logout() to delibrium_authenticator;
grant execute on function delibrium.refresh_token() to delibrium_authenticator;
grant execute on function delibrium.change_password(bigint, text) to delibrium_authenticator;
grant execute on function delibrium.config(bigint, text, text) to delibrium_authenticator;
