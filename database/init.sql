begin;
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set db_user `echo $DB_USER`
\set db_anon `echo $DB_ANON_ROLE`
\set db_name `echo $DB_NAME`
\set db_schema `echo $DB_SCHEMA`
\set authenticator_pass `echo $DB_PASS`

drop role if exists :db_user;
create role :db_user with login password :'authenticator_pass';

create role :db_anon;
grant :db_anon to :db_user;

\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''

\echo :quoted_jwt_secret

alter database :db_name set "app.jwt_secret" to :quoted_jwt_secret;
alter database :db_name set "app.debug" to 'f';

create extension if not exists plpython3u;
create extension if not exists pgcrypto;

\ir ./libs/pgjwt/schema.sql

-- create extension if not exists pgjwt;

create schema if not exists aula;
create schema if not exists aula_secure;

-- \ir config.sql
\ir types/init.sql
\ir libs/init.sql
\ir authorization/init.sql
\ir model/init.sql
\ir rpc/init.sql
\ir authorization/permissions.sql

-- Create initial data

\ir data/init.sql

commit;
