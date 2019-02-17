----------
--  user
----------

create table if not exists aula.users (
    id            bigserial         primary key,
    school_id     bigint            references aula.school (id),
    created_by    bigint            references aula.users (id),
    created_at    timestamptz       not null default now(),
    changed_by    bigint            not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at    timestamptz       not null default now(),
    user_login_id bigint references aula_secure.user_login (id),
    first_name    text              not null,
    last_name     text              not null,
    config        jsonb             default '{}',
    picture       text,
    email         text
);

alter table aula.school add column created_by bigint references aula.users (id);
alter table aula_secure.user_login add column aula_user_id bigint references aula.users (id) on delete cascade;
alter table aula_secure.user_login add column created_by bigint references aula.users (id);
alter table aula_secure.user_login add column changed_by bigint references aula.users (id);
