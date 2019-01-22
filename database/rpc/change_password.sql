create or replace function aula.change_password(user_id bigint, old_password text, new_password text)
   returns void
   language plpgsql
as $$
declare
  school_id bigint;
 begin
 raise info 'CHANGE PASS: user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
  if current_setting('request.jwt.claim.user_group') = 'admin' then
   update aula_secure.user_login set password = new_password where id = user_id;
  elsif current_setting('request.jwt.claim.user_group') = 'school_admin' then
    select aula.users.school_id into school_id from aula.users where aula.users.id = user_id;
    if school_id = current_setting('request.jwt.claim.school_id') then
      update aula_secure.user_login set aula_secure.user_login.password = new_password where id = user_id;
    end if;
  else
   perform aula_secure.change_password(request.user_id(), old_password, new_password);
  end if;
 end
$$;

