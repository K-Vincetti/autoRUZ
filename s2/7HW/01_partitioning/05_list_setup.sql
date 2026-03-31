SET search_path TO lab_partition;

DROP TABLE IF EXISTS orders_list CASCADE;

CREATE TABLE orders_list (
    id BIGINT NOT NULL,
    created_at DATE NOT NULL,
    region TEXT NOT NULL,
    amount NUMERIC,
    PRIMARY KEY (id, region)
) PARTITION BY LIST (region);

CREATE TABLE orders_list_moscow PARTITION OF orders_list
FOR VALUES IN ('Moscow');

CREATE TABLE orders_list_spb PARTITION OF orders_list
FOR VALUES IN ('SPB');

CREATE TABLE orders_list_other PARTITION OF orders_list
DEFAULT;

CREATE INDEX idx_orders_list_moscow_amount ON orders_list_moscow (amount);
CREATE INDEX idx_orders_list_spb_amount ON orders_list_spb (amount);
CREATE INDEX idx_orders_list_other_amount ON orders_list_other (amount);