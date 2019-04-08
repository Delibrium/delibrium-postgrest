create or replace function aula_secure.user_id(school_id bigint, username text, password text)
  returns table (uid bigint, sc integer)
  language plpgsql
as $$
  begin
    set "request.jwt.claim.user_group" TO 'admin';

    return query
      select
        aula.users.id,
        aula_secure.user_login.session_count
      from
        aula.users,
        aula_secure.user_login
      where
        aula.users.user_login_id = aula_secure.user_login.id
        and aula.users.school_id = user_id.school_id
        and aula.users.username = user_id.username
        and aula_secure.user_login.password = crypt(
          user_id.password,
          aula_secure.user_login.password
        );

    set "request.jwt.claim.user_group" TO '';
  end;
$$;

grant execute on function aula_secure.user_id(bigint, text, text)   to aula_authenticator;
