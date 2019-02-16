create or replace function delegation.delegated(user_id bigint, idea_id bigint)
  returns table (id bigint)
  language plpgsql
as $$
begin
  return query with recursive ids as
      (select from_user from aula.delegation inner join aula.idea on
        aula.idea.topic = aula.delegation.context_topic
        where to_user = user_id and aula.idea.id = idea_id
       union
       select d.from_user from aula.delegation d
      inner join ids i on
        d.to_user = i.from_user and
        d.to_user != user_id
      )
  select from_user from ids;
end;
$$;
