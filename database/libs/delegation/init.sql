drop schema if exists delegation cascade;
create schema delegation;
grant usage on schema delegation to aula_authenticator;

\ir delegated.sql
\ir delegated_topic.sql
\ir is_delegated.sql
\ir delete_vote.sql
