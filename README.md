1. Create the user that is going to be the owner of the database

 $ createuser aula

2. Create the database

 $ createdb aula -O aula

3. Set the user password on Postgres:

 $ psql
 $ postgres=# alter user aula with password 'pass'

4. Create the database schema

 $ psql aula -f aula.schema.sql

5. Edit the last lines of permissions.sql according to the comments

6. Configure the permissions on the tables:

 $ psql aula -f permissions.sql

7. Edit aula.conf accoring to your database name, user, password and jwt secret (the same used on permissions)

8. Start postgrest using your configuration file:
 
 $ postgrest aula.conf
