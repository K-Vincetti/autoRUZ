-- OFF
DROP PUBLICATION IF EXISTS pub_orders;

CREATE PUBLICATION pub_orders
FOR TABLE lab_partition.orders_range
WITH (publish_via_partition_root = false);

EXPLAIN (VERBOSE)
INSERT INTO lab_partition.orders_range
VALUES (300, '2026-02-10', 'Moscow', 111);

-- ON
DROP PUBLICATION pub_orders;

CREATE PUBLICATION pub_orders
FOR TABLE lab_partition.orders_range
WITH (publish_via_partition_root = true);

EXPLAIN (VERBOSE)
INSERT INTO lab_partition.orders_range
VALUES (301, '2026-02-10', 'Moscow', 222);