SET search_path TO lab_partition;

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)
SELECT *
FROM orders_list
WHERE region = 'Moscow'
  AND amount = 100;