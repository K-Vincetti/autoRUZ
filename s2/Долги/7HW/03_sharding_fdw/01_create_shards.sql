SET search_path TO lab_partition;

DROP TABLE IF EXISTS shard1_orders;
DROP TABLE IF EXISTS shard2_orders;

CREATE TABLE shard1_orders (
    id BIGINT,
    region TEXT,
    amount NUMERIC
);

CREATE TABLE shard2_orders (
    id BIGINT,
    region TEXT,
    amount NUMERIC
);