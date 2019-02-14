create or replace function aula_secure.check_user()
 returns void
 language plpgsql
as $$
declare
  user_id integer;
  user_role text;
  session_count_claim integer;
  session_count integer;
begin
  if current_setting('request.jwt.claim.user_id', true) != '' then
    if current_setting('app.debug') then
      raise info 'user_id %', current_setting('request.jwt.claim.user_id', true) = '';
    end if;
    user_id := current_setting('request.jwt.claim.user_id', true);
  else
    return;
  end if;
  if current_setting('request.jwt.claim.session_count', true) != '' then
    if current_setting('app.debug') then
      raise info '%', current_setting('request.jwt.claim.session_count', true);
    end if;
    session_count_claim := current_setting('request.jwt.claim.session_count', true);
  else
    return;
  end if;

  if user_id is not null and session_count_claim is not null then
    select aula_secure.user_login.session_count into session_count from aula_secure.user_login where aula_user_id = cast(user_id as numeric);
    if session_count > cast(session_count_claim as numeric) then
      raise exception 'session expired'
        using hint = 'login again', detail = '';
    end if;
  end if;
end
$$;

grant execute on function aula_secure.check_user() to aula_authenticator;
