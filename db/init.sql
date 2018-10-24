\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''
\set delibrium_database `echo $DELIBRIUM_DB`

begin;

alter database :delibrium_database set "app.jwt_secret" to :quoted_jwt_secret;

\echo # Creating Delibrium models
\ir delibrium.schema.sql
\echo # Creatin auth system
\ir auth/auth.sql
\echo # Creating Permissions
\ir delibrium.permissions.sql

commit;
