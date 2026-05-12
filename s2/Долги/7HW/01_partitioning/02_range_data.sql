SET search_path TO lab_partition;

INSERT INTO orders_range (id, created_at, region, amount) VALUES
-- январь
(1, '2026-01-10', 'Moscow', 100),
(2, '2026-01-15', 'SPB', 200),

-- февраль
(3, '2026-02-10', 'Moscow', 300),
(4, '2026-02-20', 'SPB', 400),

-- март
(5, '2026-03-05', 'Moscow', 500),
(6, '2026-03-25', 'SPB', 600);