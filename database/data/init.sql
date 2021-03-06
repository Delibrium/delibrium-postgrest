\set categories_path '\'' :base_dir '/data/categories.csv\''
\set school_path '\'' :base_dir '/data/school.csv\''
\set pages_path '\'' :base_dir '/data/pages.csv\''

-- Insert special school
copy aula.school (id,created_at, changed_at, name, config, created_by) from :school_path with (delimiter ',', format csv, quote '"', header true);

-- Insert admin user
insert into aula_secure.user_login (school_id, login, password) values ( 1, 'admin', 'password');
insert into aula.users (school_id, user_login_id, first_name, last_name, changed_by, username) values (1, 1, 'Admin', 'aula', 1, 'admin');
update aula_secure.user_login set aula_user_id = 1 where id = 1;
insert into aula.user_group (school_id, user_id, group_id) values(1, 1, 'admin');

-- Insert student
insert into aula_secure.user_login (school_id, login, password) values ( 1, 'student', 'password');
insert into aula.users (school_id, user_login_id, first_name, last_name, username, changed_by) values (1, 2, 'Student', 'Example', 'student', 1);
update aula_secure.user_login set aula_user_id = 2 where id = 2;
insert into aula.user_group (school_id, user_id, group_id) values(1, 2, 'student');

-- Insert Class
insert into aula.idea_space (school_id, created_by, changed_by, title, description, slug) values (1,1,1,'Klass', 'Test Klass', 'test-klass');

-- Import categories
copy aula.category (id,school_id, name, description, image,def,position) from :categories_path with (delimiter ',', format csv, quote '"', header true);

-- Import pages
copy aula.page (id,created_by, created_at,changed_by, changed_at,school_id, name, public,content,config) from :pages_path with (delimiter ',', format csv, quote '"', header true);
