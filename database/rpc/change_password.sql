create or replace function aula.change_password(user_id bigint, old_password text, new_password text)
   returns void
   language plpgsql
as $$
declare
  changes_num integer;
begin
  with row_changes as (
    update aula_secure.user_login
      set password = new_password, config = config #- '{temp_password}'
      where
        aula_user_id = user_id
        and
        password = crypt(old_password, password) returning 1)
  select count(*) from row_changes into changes_num;

  if changes_num = 0 then
   raise exception 'Check password';
  end if;

end
$$;

grant execute on function aula.change_password(bigint, text, text) to aula_authenticator;
