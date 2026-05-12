DROP INDEX IF EXISTS service.hw_ads_costof_btree;
DROP INDEX IF EXISTS service.hw_ads_status_btree;
DROP INDEX IF EXISTS service.hw_ads_headertext_btree;
DROP INDEX IF EXISTS service.hw_ads_sellerid_btree;
DROP INDEX IF EXISTS service.hw_ads_status_hash;
DROP INDEX IF EXISTS service.hw_ads_sellerid_hash;
DROP INDEX IF EXISTS service.hw_ads_seller_status_btree;

CREATE INDEX hw_ads_seller_status_btree
ON service.ads USING btree(sellerid, status);

ANALYZE service.ads;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE costof > 500000 AND costof < 2000000;

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE status = 'active';

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE headertext LIKE '%car%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE headertext LIKE 'Selling%';

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM service.ads
WHERE sellerid IN (1,2,3,4,5,6,7,8,9,10);
