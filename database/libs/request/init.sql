drop schema if exists request cascade;
create schema request;
grant usage on schema request to aula_authenticator;

\ir env_var.sql
\ir jwt_claim.sql
\ir cookie.sql
\ir header.sql
\ir user_id.sql
\ir school_id.sql
\ir user_role.sql
