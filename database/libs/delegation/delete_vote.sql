create or replace function delegation.delete_vote()
  returns trigger
  language plpgsql
as $$
begin
  delete from aula.idea_vote where user_id in (select delegation.delegated(request.user_id(), OLD.idea));
  delete from aula.idea_vote where id = OLD.id;
  return OLD;
end;
$$;
