SET search_path TO lab_partition;

INSERT INTO orders_hash (id, created_at, region, amount) VALUES
(1, '2026-01-01', 'Moscow', 100),
(2, '2026-01-02', 'SPB', 200),
(3, '2026-01-03', 'Kazan', 300),
(4, '2026-01-04', 'Moscow', 400),
(5, '2026-01-05', 'SPB', 500),
(6, '2026-01-06', 'Kazan', 600);