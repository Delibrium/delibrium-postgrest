begin;

create extension if not exists plpython3u;
create extension if not exists pgcrypto;
create extension if not exists pgjwt;

\ir libs/init.sql
\ir model/init.sql
\ir rpc/init.sql
\ir authorization/init.sql

-- Create initial data

\ir data/init.sql

commit;
