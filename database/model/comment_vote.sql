create table if not exists aula.comment_vote (
    school_id bigint            references aula.school (id),
    comment    bigint           not null references aula.comment (id),
    created_by bigint           not null references aula.users (id),
    created_at timestamptz      not null default now(),
    changed_by bigint           not null default request.user_id() references aula.users (id) references aula.users (id),
    changed_at timestamptz      not null default now(),
    val        aula.up_down     not null
);
