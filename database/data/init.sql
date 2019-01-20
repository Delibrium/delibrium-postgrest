-- Insert special school
insert into aula.school(id, name) values (1, 'Aula');

-- Insert admin user
insert into aula_secure.user_login (school_id, login, password) values ( 1, 'admin', 'password');
insert into aula.users (school_id, user_login_id, first_name, last_name) values (1, 1, 'Admin', 'aula');
insert into aula.user_group (school_id, user_id, group_id) values(1, 1, 'admin');

-- Insert student
insert into aula_secure.user_login (school_id, login, password) values ( 1, 'student', 'password');
insert into aula.users (school_id, user_login_id, first_name, last_name) values (1, 2, 'Student', 'Example');
insert into aula.user_group (school_id, user_id, group_id) values(1, 2, 'student');

-- Insert Class
insert into aula.idea_space (school_id, created_by, changed_by, title, description, slug) values (1,1,1,'Class', 'Test class', 'test');

