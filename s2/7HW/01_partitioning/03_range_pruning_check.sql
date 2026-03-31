SET search_path TO lab_partition;

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)
SELECT *
FROM orders_range
WHERE created_at = DATE '2026-02-10';