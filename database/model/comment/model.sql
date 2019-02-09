create table if not exists aula.comment (
    school_id      bigint      references aula.school (id),
    id             bigserial   primary key,
    created_by     bigint      not null references aula.users (id),
    created_at     timestamptz not null default now(),
    changed_by     bigint      not null default request.user_id() references aula.users (id),
    changed_at     timestamptz not null default now(),
    text           text        not null,
    is_deleted     boolean default 'F',
    parent_comment bigint      references aula.comment (id),
    parent_idea    bigint      references aula.idea (id)
);
