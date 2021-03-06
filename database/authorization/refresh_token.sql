create or replace function aula.refresh_token() returns text as $$
declare
  usr record;
  token text;
begin
    if current_setting('app.debug') then
      raise info 'TOKEN %', current_setting('request.jwt', true);
    end if;

    EXECUTE format(
    ' select row_to_json(u.*) as j'
        ' from aula_secure.user_login as u'
        ' where u.aula_user_id = cast($1 as numeric)')
    INTO usr
    USING current_setting('request.jwt.claim.user_id', true);

    if usr is NULL then
      raise exception 'user not found';
    else
      select sign(
       current_setting('request.jwt', true), current_setting('app.jwt_secret')
      )
      into token;
      return token;
    end if;
end
$$ stable security definer language plpgsql;

grant execute on function aula.refresh_token()                      to aula_authenticator;
