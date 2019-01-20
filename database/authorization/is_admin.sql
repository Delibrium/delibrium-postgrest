create or replace function aula.is_admin(school_id bigint)
  returns boolean
  language plpgsql
as $$
declare
  gid aula.group_id;
begin
  raise info 'CHECK IS ADMIN';
  raise info 'user_group => %, school_id => %', current_setting('request.jwt.claim.user_group', true), current_setting('request.jwt.claim.school_id', true);
  return (current_setting('request.jwt.claim.user_group', true) = 'admin') or (cast(current_setting('request.jwt.claim.school_id', true) as "numeric") = school_id and current_setting('request.jwt.claim.user_group', true) = 'school_admin');
end
$$;
