SET search_path TO lab_partition;

DROP VIEW IF EXISTS orders_router;

CREATE VIEW orders_router AS
SELECT * FROM shard1_orders_fdw
UNION ALL
SELECT * FROM shard2_orders_fdw;