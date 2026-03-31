SET search_path TO lab_partition;

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)
SELECT *
FROM orders_hash
WHERE id = 3;