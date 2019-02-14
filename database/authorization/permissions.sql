revoke all privileges on function aula.refresh_token() from public;

grant usage on schema aula to aula_authenticator;
grant all on all tables in schema aula to aula_authenticator;
grant usage, select on all sequences in schema aula to aula_authenticator;

grant usage on schema aula_secure                                   to aula_authenticator;
grant all on all tables in schema aula_secure                       to aula_authenticator;
grant usage, select on all sequences in schema aula_secure          to aula_authenticator;
