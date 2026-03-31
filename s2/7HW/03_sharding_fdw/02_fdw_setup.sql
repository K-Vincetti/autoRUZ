CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS shard_server CASCADE;

CREATE SERVER shard_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'postgres', port '5432');

CREATE USER MAPPING FOR CURRENT_USER
SERVER shard_server
OPTIONS (user 'postgres');