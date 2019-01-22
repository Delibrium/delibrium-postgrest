create or replace function aula_secure.change_password(user_id bigint, old_password text, new_password text)
   returns void
   language plpgsql
as $$
 begin
 raise info 'CHANGE PASS: %, %, user_group => %, user_id => %, school_id => %', old_password, new_password, current_setting('request.jwt.claim.user_group', true),current_setting('request.jwt.claim.user_id', true), current_setting('request.jwt.claim.school_id', true);
 update aula_secure.user_login set password = new_password where id = user_id and password = crypt(old_password, aula_secure.user_login.password);
 end
$$;
