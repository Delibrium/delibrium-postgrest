create or replace function delegation.delegated_topic(user_id bigint, topic_id bigint)
  returns table (id bigint)
  language plpgsql
as $$
begin
  return query with recursive ids as
      (select from_user from aula.delegation
        where to_user = user_id and context_topic = topic_id
       union
       select d.from_user from aula.delegation d
      inner join ids i on
        d.to_user = i.from_user and
        d.to_user != user_id
      )
  select from_user from ids;
end;
$$;
