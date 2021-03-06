create table if not exists aula.idea_vote (
    school_id bigint                references aula.school (id),
    idea       bigint               not null references aula.idea (id),
    created_by bigint               not null references aula.users (id),
    created_at timestamptz          not null default now(),
    changed_by bigint               not null default request.user_id() references aula.users (id),
    changed_at timestamptz          not null default now(),
    user_id    bigint               references aula.users(id),
    val        aula.idea_vote_value not null
);

alter table aula.idea_vote add unique (idea, user_id);
