SET search_path TO lab_partition;

DROP FOREIGN TABLE IF EXISTS shard1_orders_fdw;
DROP FOREIGN TABLE IF EXISTS shard2_orders_fdw;

CREATE FOREIGN TABLE shard1_orders_fdw (
    id BIGINT,
    region TEXT,
    amount NUMERIC
)
SERVER shard_server
OPTIONS (table_name 'shard1_orders');

CREATE FOREIGN TABLE shard2_orders_fdw (
    id BIGINT,
    region TEXT,
    amount NUMERIC
)
SERVER shard_server
OPTIONS (table_name 'shard2_orders');