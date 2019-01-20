create extension if not exists pgcrypto;
create extension if not exists pgjwt;

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

drop trigger if exists encrypt_pass on aula_secure.user_login;
create trigger encrypt_pass
  before insert or update on aula_secure.user_login
  for each row
  execute procedure aula_secure.encrypt_pass();
