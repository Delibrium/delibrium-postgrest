create schema if not exists delibrium;
create schema if not exists delibrium_secure;

create table if not exists delibrium.community (
    id         bigserial     primary key,
    created_at timestamptz   not null default now(),
    changed_at timestamptz   not null default now(),
    name       text,
    config     jsonb
);

create table if not exists delibrium_secure.user_login (
    id                 bigserial     primary key,
    community_id          bigint        references delibrium.community (id),
    created_at         timestamptz   not null default now(),
    changed_at         timestamptz   not null default now(),
    session_count  int default 0,
    login              text          not null,
    password           text          not null
);

----------
--  user
----------

create table if not exists delibrium.users (
    id            bigserial         primary key,
    community_id     bigint            references delibrium.community (id),
    created_by    bigint            references delibrium.users (id),
    created_at    timestamptz       not null default now(),
    changed_by    bigint            references delibrium.users (id),
    changed_at    timestamptz       not null default now(),
    user_login_id bigint references delibrium_secure.user_login (id),
    first_name    text              not null,
    last_name     text              not null,
    email         text
);

alter table delibrium.community add column created_by bigint references delibrium.users (id);
alter table delibrium_secure.user_login add column delibrium_user_id bigint references delibrium.users (id);
alter table delibrium_secure.user_login add column created_by bigint references delibrium.users (id);
alter table delibrium_secure.user_login add column changed_by bigint references delibrium.users (id);

-------------
--  Idea
-------------

create table if not exists delibrium.idea_space (
    id          bigserial   primary key,
    community_id bigint        references delibrium.community (id),
    created_by  bigint      not null references delibrium.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references delibrium.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null
);

create type delibrium.phase as enum
    ('edit_topics', 'feasibility', 'vote', 'finished');

create table if not exists delibrium.topic (
    id          bigserial   primary key,
    community_id   bigint      references delibrium.community (id),
    created_by  bigint      not null references delibrium.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references delibrium.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    image       text        not null,
    idea_space  bigint      references delibrium.idea_space (id),  -- 'null' == 'communityspace'
    phase       delibrium.phase  not null
);

create table if not exists delibrium.category (
    id          bigserial   primary key,
    community_id   bigint      references delibrium.community (id),
    name        text        not null,
    description text
);

create table if not exists delibrium.feasible (
    id         bigserial   primary key,
    community_id  bigint      references delibrium.community (id),
    created_by bigint      not null references delibrium.users (id),
    created_at timestamptz not null default now(),
    changed_by bigint      not null references delibrium.users (id),
    changed_at timestamptz not null default now(),
    val        bool        not null,
    reason     text
);

create table if not exists delibrium.idea (
    id          bigserial   primary key,
    community_id   bigint      references delibrium.community (id),
    created_by  bigint      not null references delibrium.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references delibrium.users (id),
    changed_at  timestamptz not null default now(),
    title       text        not null,
    description text        not null,
    category    bigint      references delibrium.category (id),
    idea_space  bigint      references delibrium.idea_space (id),  -- 'null' == 'communityspace'
    topic       bigint      references delibrium.topic (id),
    feasible    bigint      references delibrium.feasible (id)
);

create table if not exists delibrium.idea_like (
    community_id bigint        references delibrium.community (id),
    idea        bigint      not null references delibrium.idea (id),
    created_by  bigint      not null references delibrium.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references delibrium.users (id),
    changed_at  timestamptz not null default now()
);

create type delibrium.idea_vote_value as enum
    ('yes', 'no');

create table if not exists delibrium.idea_vote (
    community_id bigint                references delibrium.community (id),
    idea       bigint               not null references delibrium.idea (id),
    created_by bigint               not null references delibrium.users (id),
    created_at timestamptz          not null default now(),
    changed_by bigint               not null references delibrium.users (id),
    changed_at timestamptz          not null default now(),
    val        delibrium.idea_vote_value not null
);


----------------------------------------------------------------------
-- comment

create table if not exists delibrium.comment (
    community_id      bigint      references delibrium.community (id),
    id             bigserial   primary key,
    created_by     bigint      not null references delibrium.users (id),
    created_at     timestamptz not null default now(),
    changed_by     bigint      not null references delibrium.users (id),
    changed_at     timestamptz not null default now(),
    text           text        not null,
    parent_comment bigint      references delibrium.comment (id),
    parent_idea    bigint      references delibrium.idea (id)
);

create type delibrium.up_down as enum
    ('up', 'down');

create table if not exists delibrium.comment_vote (
    community_id bigint            references delibrium.community (id),
    comment    bigint           not null references delibrium.comment (id),
    created_by bigint           not null references delibrium.users (id),
    created_at timestamptz      not null default now(),
    changed_by bigint           not null references delibrium.users (id),
    changed_at timestamptz      not null default now(),
    val        delibrium.up_down     not null
);


----------------------------------------------------------------------
-- idea space

create table if not exists delibrium.community_class (
    community_id bigint        references delibrium.community (id),
    id          bigserial   primary key,
    created_by  bigint      not null references delibrium.users (id),
    created_at  timestamptz not null default now(),
    changed_by  bigint      not null references delibrium.users (id),
    changed_at  timestamptz not null default now(),
    class_name  text        not null,
    community_year text        not null
);

create type delibrium.group_id as enum
    ('student', 'class_guest', 'community_guest', 'moderator', 'principal', 'community_admin', 'admin');

create table if not exists delibrium.user_group (
    community_id    bigint         references delibrium.community (id),
    user_id      bigint         not null references delibrium.users (id) on delete cascade,
    group_id     delibrium.group_id  not null,
    community_class bigint         references delibrium.community_class (id),
    unique (user_id, group_id, community_class)
);

create table if not exists delibrium.delegation (
    id                 bigserial   primary key,
    community_id bigint   references  delibrium.community (id),
    created_by         bigint      not null references delibrium.users (id),
    created_at         timestamptz not null default now(),
    changed_by         bigint      not null references delibrium.users (id),
    changed_at         timestamptz not null default now(),
    context_idea_space bigint      references delibrium.idea_space (id),
        -- 'null' == 'communityspace'
    context_topic      bigint      references delibrium.topic (id),
    context_idea       bigint      references delibrium.idea (id),
    from_user          bigint      not null references delibrium.users (id),
    to_user            bigint      not null references delibrium.users (id)
    -- fixme: constraint: at most one of context_idea_space,
    -- context_topic, context_idea is not null.
);
