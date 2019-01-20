create table if not exists aula.topic (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    image       text        not null,
    idea_space  bigint      references aula.idea_space (id),  -- 'null' == 'schoolspace'
    phase       aula.phase  not null
);

alter table aula.topic add column config jsonb default '{}';
