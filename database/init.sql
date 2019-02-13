begin;

create extension if not exists plpython3u;
create extension if not exists pgcrypto;
create extension if not exists pgjwt;

create schema if not exists aula;
create schema if not exists aula_secure;

\ir types/init.sql
\ir libs/init.sql
\ir authorization/init.sql
\ir model/init.sql
\ir rpc/init.sql

-- Create initial data

\ir data/init.sql

commit;
