create table if not exists aula.school (
    id         bigserial     primary key,
    created_at timestamptz   not null default now(),
    changed_at timestamptz   not null default now(),
    name       text,
    config     jsonb default '{}'
);
