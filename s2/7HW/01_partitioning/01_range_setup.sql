SET search_path TO lab_partition;

DROP TABLE IF EXISTS orders_range CASCADE;

CREATE TABLE orders_range (
    id BIGINT NOT NULL,
    created_at DATE NOT NULL,
    region TEXT NOT NULL,
    amount NUMERIC,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_range_2026_01 PARTITION OF orders_range
FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE orders_range_2026_02 PARTITION OF orders_range
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE TABLE orders_range_2026_03 PARTITION OF orders_range
FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE INDEX idx_orders_range_2026_01_amount ON orders_range_2026_01 (amount);
CREATE INDEX idx_orders_range_2026_02_amount ON orders_range_2026_02 (amount);
CREATE INDEX idx_orders_range_2026_03_amount ON orders_range_2026_03 (amount);