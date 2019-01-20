create table if not exists aula_secure.user_login (
    id                 bigserial     primary key,
    school_id          bigint        references aula.school (id),
    created_at         timestamptz   not null default now(),
    changed_at         timestamptz   not null default now(),
    session_count  int default 0,
    login              text          not null,
    password           text          not null
);

alter table aula_secure.user_login add column config jsonb default '{}';
alter table aula_secure.user_login add constraint unique_login unique (school_id, login);
