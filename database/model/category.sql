create table if not exists aula.category (
    id          bigserial   primary key,
    school_id   bigint      references aula.school (id),
    name        text        not null,
    description text,
    image       text
);
