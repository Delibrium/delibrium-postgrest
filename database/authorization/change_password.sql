create or replace function aula_secure.change_password(user_id bigint, new_password text)
   returns void
   language plpgsql
as $$
declare
  school_id bigint;
 begin
 raise info 'CHANGE PASS: user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
  if current_setting('request.jwt.claim.user_group') = 'admin' then
    select aula.users.school_id into school_id from aula.users where aula.users.id = user_id;
  else
    school_id := cast(current_setting('request.jwt.claim.school_id') as numeric);
  end if;

   insert into aula_secure.user_login (school_id, aula_user_id, password) values (school_id, user_id, new_password)
    on conflict (aula_user_id) do update set password = new_password;
 end
$$;

