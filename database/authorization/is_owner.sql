create or replace function aula.is_owner(user_id bigint)
  returns boolean
  language plpgsql
as $$
begin
  return (cast(current_setting('request.jwt.claim.user_id') as numeric) = user_id);
end
$$;
