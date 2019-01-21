create or replace function aula.from_school(school_id bigint)
  returns boolean
  language plpgsql
as $$
begin
  return (cast(current_setting('request.jwt.claim.school_id') as numeric) = school_id);
end
$$;
