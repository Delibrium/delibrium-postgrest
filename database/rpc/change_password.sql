create or replace function aula.change_password(user_id bigint, password text)
   returns void
   language plpgsql
as $$
 begin
 raise info 'CHANGE PASS: user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
   perform aula_secure.change_password(user_id, password);
 end
$$;

