drop trigger if exists encrypt_pass on aula_secure.user_login;
create trigger encrypt_pass
  before insert or update on aula_secure.user_login
  for each row
  execute procedure aula_secure.encrypt_pass();
