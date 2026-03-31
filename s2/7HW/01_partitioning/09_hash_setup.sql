SET search_path TO lab_partition;

DROP TABLE IF EXISTS orders_hash CASCADE;

CREATE TABLE orders_hash (
    id BIGINT NOT NULL,
    created_at DATE NOT NULL,
    region TEXT NOT NULL,
    amount NUMERIC,
    PRIMARY KEY (id)
) PARTITION BY HASH (id);

CREATE TABLE orders_hash_p0 PARTITION OF orders_hash
FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE orders_hash_p1 PARTITION OF orders_hash
FOR VALUES WITH (MODULUS 3, REMAINDER 1);

CREATE TABLE orders_hash_p2 PARTITION OF orders_hash
FOR VALUES WITH (MODULUS 3, REMAINDER 2);

CREATE INDEX idx_orders_hash_p0_amount ON orders_hash_p0 (amount);
CREATE INDEX idx_orders_hash_p1_amount ON orders_hash_p1 (amount);
CREATE INDEX idx_orders_hash_p2_amount ON orders_hash_p2 (amount);