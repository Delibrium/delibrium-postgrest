create or replace function aula.delete_vote(userid bigint, idea_id bigint)
  returns void
  language plpgsql
as $$
begin
  delete from aula.idea_vote where user_id in (select delegation.delegated(request.user_id(), idea_id));
  delete from aula.idea_vote where user_id = userid;
end;
$$;

grant execute on function aula.delete_vote (bigint, bigint) to aula_authenticator;

