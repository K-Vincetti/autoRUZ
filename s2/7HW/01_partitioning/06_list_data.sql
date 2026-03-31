SET search_path TO lab_partition;

INSERT INTO orders_list (id, created_at, region, amount) VALUES
(1, '2026-01-10', 'Moscow', 100),
(2, '2026-01-11', 'Moscow', 150),

(3, '2026-02-10', 'SPB', 200),
(4, '2026-02-11', 'SPB', 250),

(5, '2026-03-10', 'Kazan', 300);