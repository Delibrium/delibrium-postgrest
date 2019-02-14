\set db_user aula
\set db_name aula
\set jwt_secret 'Xh3d3SeWWQTn85sDZ8ytKmtS36HJtEhJ'
\set quoted_jwt_secret '\'' :jwt_secret '\''

grant aula_authenticator to :db_user;
alter database :db_name set "app.jwt_secret" to :quoted_jwt_secret;
alter database :db_name set "app.debug" to 'f';
