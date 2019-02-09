alter table aula.topic enable row level security;

drop policy if exists school_admin_topic on aula.topic;
create policy
  school_admin_topic
  on aula.topic
  using
    (aula.is_admin(school_id) or aula.from_school(school_id))
  with check
    (aula.is_admin(school_id) or aula.is_moderator(school_id));
