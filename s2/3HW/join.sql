EXPLAIN (ANALYZE, BUFFERS)
SELECT a.ad_id, v.brand
FROM service.ads a
JOIN service.vehicles v
ON a.vehicle_id = v.vehicle_id
WHERE a.price > 1000000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT a.ad_id, s.seller_id
FROM service.ads a
JOIN service.sellers s
ON a.seller_id = s.seller_id
WHERE a.status_id = 1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_id, count(a.ad_id)
FROM service.users u
JOIN service.sellers s
ON u.user_id = s.user_id
JOIN service.ads a
ON a.seller_id = s.seller_id
GROUP BY u.user_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT v.brand, count(a.ad_id)
FROM service.ads a
JOIN service.vehicles v
ON a.vehicle_id = v.vehicle_id
GROUP BY v.brand;

EXPLAIN (ANALYZE, BUFFERS)
SELECT a.ad_id, u.email
FROM service.ads a
JOIN service.sellers s
ON a.seller_id = s.seller_id
JOIN service.users u
ON s.user_id = u.user_id
WHERE a.price > 2000000;