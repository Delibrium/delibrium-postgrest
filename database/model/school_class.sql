create table if not exists aula.school_class (
    school_id bigint        references aula.school (id),
    id          bigserial   primary key,
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at  timestamptz not null default now(),
    class_name  text        not null,
    school_year text        not null
);
