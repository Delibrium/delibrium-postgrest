create or replace function aula.reset_password(school_id bigint, user_id bigint)
  returns jsonb
  language plpgsql
as $$
declare
  new_password text;
begin
  if (aula.is_admin(school_id)) then
    begin
      select aula.random_password() into new_password;
      update aula_secure.user_login set config = jsonb_set(config, '{temp_password}', to_jsonb(new_password)), password = new_password where aula_user_id = user_id;
    end;

    return json_build_object('new_password', new_password);
  end if;
end
$$;

grant execute on function aula.reset_password(bigint, bigint) to aula_authenticator;

