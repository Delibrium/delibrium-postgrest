create schema if not exists aula;
create schema if not exists aula_secure;

create table if not exists aula.school (
    id         bigserial     primary key,
    created_at timestamptz   not null default now(),
    changed_at timestamptz   not null default now(),
    name       text,
    config     jsonb
);

create table if not exists aula_secure.user_login (
    id                 bigserial     primary key,
    school_id          bigint        references aula.school (id),
    created_at         timestamptz   not null default now(),
    changed_at         timestamptz   not null default now(),
    session_count  int default 0,
    login              text          not null,
    password           text          not null
);

----------
--  user
----------

create table if not exists aula.users (
    id            bigserial         primary key,
    school_id     bigint            references aula.school (id),
    created_by    bigint            references aula.users (id),
    created_at    timestamptz       not null default now(),
    changed_by    bigint            references aula.users (id),
    changed_at    timestamptz       not null default now(),
    user_login_id bigint references aula_secure.user_login (id),
    first_name    text              not null,
    last_name     text              not null,
    email         text
);

alter table aula.school add column created_by bigint references aula.users (id);
alter table aula_secure.user_login add column aula_user_id bigint references aula.users (id);
alter table aula_secure.user_login add column created_by bigint references aula.users (id);
alter table aula_secure.user_login add column changed_by bigint references aula.users (id);

-------------
--  Idea
-------------

create table if not exists aula.idea_space (
    id          bigserial   primary key,
    school_id bigint        references aula.school (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references aula.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    slug        text
);

create type aula.phase as enum
    ('edit_topics', 'feasibility', 'vote', 'finished');

create table if not exists aula.topic (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references aula.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    image       text        not null,
    idea_space  bigint      references aula.idea_space (id),  -- 'null' == 'schoolspace'
    phase       aula.phase  not null
);

-- create type aula.category as enum
--     ('rule', 'equipment', 'class', 'time', 'environment');

create table if not exists aula.category (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    name        text        not null,
    description text
);

create table if not exists aula.feasible (
    id         bigserial   primary key,
    school_id  bigint      references aula.school (id),
    created_by bigint      not null references aula.users (id),
    created_at timestamptz not null default now(),
    changed_by bigint      not null references aula.users (id),
    changed_at timestamptz not null default now(),
    val        bool        not null,
    reason     text
);

create table if not exists aula.idea (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references aula.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    category    bigint      references aula.category (id),
    idea_space  bigint      references aula.idea_space (id),  -- 'null' == 'schoolspace'
    topic       bigint      references aula.topic (id),
    feasible    bigint      references aula.feasible (id)
);

create table if not exists aula.idea_like (
    school_id bigint        references aula.school (id),
    idea        bigint      not null references aula.idea (id),
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references aula.users (id),
    changed_at  timestamptz not null default now()
);

create type aula.idea_vote_value as enum
    ('yes', 'no');

create table if not exists aula.idea_vote (
    school_id bigint                references aula.school (id),
    idea       bigint               not null references aula.idea (id),
    created_by bigint               not null references aula.users (id),
    created_at timestamptz          not null default now(),
    changed_by bigint               not null references aula.users (id),
    changed_at timestamptz          not null default now(),
    val        aula.idea_vote_value not null
);


----------------------------------------------------------------------
-- comment

create table if not exists aula.comment (
    school_id      bigint      references aula.school (id),
    id             bigserial   primary key,
    created_by     bigint      not null references aula.users (id),
    created_at     timestamptz not null default now(),
    changed_by     bigint      not null references aula.users (id),
    changed_at     timestamptz not null default now(),
    text           text        not null,
    parent_comment bigint      references aula.comment (id),
    parent_idea    bigint      references aula.idea (id)
);

create type aula.up_down as enum
    ('up', 'down');

create table if not exists aula.comment_vote (
    school_id bigint            references aula.school (id),
    comment    bigint           not null references aula.comment (id),
    created_by bigint           not null references aula.users (id),
    created_at timestamptz      not null default now(),
    changed_by bigint           not null references aula.users (id),
    changed_at timestamptz      not null default now(),
    val        aula.up_down     not null
);


----------------------------------------------------------------------
-- idea space

create table if not exists aula.school_class (
    school_id bigint        references aula.school (id),
    id          bigserial   primary key,
    created_by  bigint      not null references aula.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references aula.users (id),
    changed_at  timestamptz not null default now(),
    class_name  text        not null,
    school_year text        not null
);

create type aula.group_id as enum
    ('student', 'class_guest', 'school_guest', 'moderator', 'principal', 'school_admin', 'admin');

create table if not exists aula.user_group (
    school_id    bigint         references aula.school (id),
    user_id      bigint         not null references aula.users (id) on delete cascade,
    group_id     aula.group_id  not null,
    school_class bigint         references aula.school_class (id),
    unique (user_id, group_id, school_class)
);

create table if not exists aula.delegation (
    id                 bigserial   primary key,
    school_id bigint   references  aula.school (id),
    created_by         bigint      not null references aula.users (id),
    created_at         timestamptz not null default now(),
    changed_by         bigint      not null references aula.users (id),
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
