create or replace function request.school_id() returns int as $$
  select
  case request.jwt_claim('school_id')
    when '' then 0
    else request.jwt_claim('school_id')::int
  end
$$ stable language sql;
