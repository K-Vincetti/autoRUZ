SET search_path TO lab_partition;

DROP TABLE IF EXISTS orders_range_copy;

CREATE TABLE orders_range_copy AS
SELECT * FROM orders_range;

SELECT tableoid::regclass, *
FROM orders_range_copy;