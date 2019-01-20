create table if not exists aula.delegation (
    id                 bigserial   primary key,
    school_id bigint   references  aula.school (id),
    created_by         bigint      not null references aula.users (id),
    created_at         timestamptz not null default now(),
    changed_by         bigint      not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at         timestamptz not null default now(),
    context_idea_space bigint      references aula.idea_space (id),
        -- 'null' == 'schoolspace'
    context_topic      bigint      references aula.topic (id),
    context_idea       bigint      references aula.idea (id),
    from_user          bigint      not null references aula.users (id),
    to_user            bigint      not null references aula.users (id)
    -- fixme: constraint: at most one of context_idea_space,
    -- context_topic, context_idea is not null.
);
