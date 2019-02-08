create or replace function aula_secure.change_password(user_id bigint, old_password text, new_password text)
   returns void
   language plpgsql
as $$
declare
  changes_num integer;
begin
 raise info 'CHANGE PASS: %, %, user_group => %, user_id => %, school_id => %', old_password, new_password, current_setting('request.jwt.claim.user_group', true),current_setting('request.jwt.claim.user_id', true), current_setting('request.jwt.claim.school_id', true);
 -- update aula_secure.user_login set password = new_password where id = user_id and password = crypt(old_password, aula_secure.user_login.password);
 with row_changes as (
  update aula_secure.user_login set password = new_password
    where
      id = user_id
      and
      password = crypt(old_password, password) returning 1)
 select count(*) from row_changes into changes_num;

 if changes_num = 0 then
  raise exception 'Check password';
 end if;

end
$$;
