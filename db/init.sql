\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''
\set delibrium_database `echo $DELIBRIUM_DB`
\set delibrium_user `echo $DELIBRIUM_DB_USER`

begin;

alter database :delibrium_database set "app.jwt_secret" to :quoted_jwt_secret;

\echo # Creating Delibrium models
\ir delibrium.schema.sql
\echo # Creatin auth system
\ir auth/lib.sql
\echo # Creating Permissions
\ir permissions/lib.sql

commit;
