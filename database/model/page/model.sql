create table if not exists aula.page (
    id            bigserial     primary key,
    created_by    bigint            not null default request.user_id() references aula.users (id),
    created_at    timestamptz       not null default now(),
    changed_by    bigint            not null default request.user_id() references aula.users (id),
    changed_at    timestamptz       not null default now(),
    school_id     bigint            references aula.school (id),
    name          text,
    public        boolean default false,
    content       text,
    config        jsonb default '{}'
);
