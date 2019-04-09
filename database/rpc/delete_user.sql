create or replace function aula.delete_user(schoolid bigint, userid bigint)
  returns void
  language plpgsql
as $$
declare
  login_id bigint;
begin
  if (aula.is_admin(schoolid)) then
    begin
      select user_login_id from aula.users where id = userid into login_id;
      update aula.users
        set
          user_login_id = null,
          first_name = 'deleted',
          last_name = 'user',
          username = 'deleted-' || id,
          config = json_build_object('deleted', to_jsonb('t'::boolean)),
          email = '',
          picture = ''
        where
          id = userid;
      delete from aula_secure.user_login where aula_user_id = login_id;
      delete from aula.user_group where user_id = userid;
    end;

  end if;
end
$$;

grant execute on function aula.delete_user(bigint, bigint) to aula_authenticator;
