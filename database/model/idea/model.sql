create table if not exists aula.idea (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    category    bigint      references aula.category (id),
    idea_space  bigint      references aula.idea_space (id),  -- 'null' == 'schoolspace'
    topic       bigint      references aula.topic (id)
);
