create or replace function delegation.is_delegated(user_id bigint, delegate_id bigint, idea_id bigint)
  returns boolean
  language plpgsql
as $$
declare
  is_del boolean;
begin
  select user_id in (select delegation.delegated(delegate_id, idea_id)) into is_del;
  return is_del;
end;
$$;
