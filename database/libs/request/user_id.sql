create or replace function request.user_id() returns int as $$
  select
  case request.jwt_claim('user_id')
  when '' then 0
    else request.jwt_claim('user_id')::int
  end
$$ stable language sql;
