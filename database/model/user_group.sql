create table if not exists aula.user_group (
    school_id    bigint         references aula.school (id),
    user_id      bigint         not null references aula.users (id) on delete cascade,
    group_id     aula.group_id  not null,
    idea_space bigint         references aula.idea_space (id),
    unique (user_id, group_id, idea_space)
);
