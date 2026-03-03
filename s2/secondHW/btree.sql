CREATE INDEX hw_ads_price_btree ON service.ads USING btree(price);
CREATE INDEX hw_ads_status_btree ON service.ads USING btree(status_id);
CREATE INDEX hw_ads_header_btree ON service.ads USING btree(header_text);
CREATE INDEX hw_ads_seller_btree ON service.ads USING btree(seller_id);

ANALYZE service.ads;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE price > 500000 AND price < 2000000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE status_id = 1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE header_text LIKE '%car%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE header_text LIKE 'Selling%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE seller_id IN (1,2,3,4,5,6,7,8,9,10);

DROP INDEX IF EXISTS service.hw_ads_price_btree;
DROP INDEX IF EXISTS service.hw_ads_status_btree;
DROP INDEX IF EXISTS service.hw_ads_header_btree;
DROP INDEX IF EXISTS service.hw_ads_seller_btree;
