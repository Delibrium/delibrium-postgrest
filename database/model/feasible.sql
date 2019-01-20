create table if not exists aula.feasible (
    id         bigserial   primary key,
    school_id  bigint      references aula.school (id),
    created_by bigint      not null references aula.users (id),
    created_at timestamptz not null default now(),
    changed_by bigint      not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at timestamptz not null default now(),
    val        bool        not null,
    reason     text
);
