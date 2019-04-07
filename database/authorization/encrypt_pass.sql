create extension if not exists pgcrypto;
-- create extension if not exists pgjwt;

create or replace function aula_secure.encrypt_pass() returns trigger
  language plpgsql
  as $$
begin
  if tg_op = 'INSERT' or new.password <> old.password then
    new.password = crypt(new.password, gen_salt('bf'));
  end if;
  return new;
end
$$;

grant execute on function aula_secure.encrypt_pass() to aula_authenticator;


