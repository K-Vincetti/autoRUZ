CREATE INDEX gin_ads_doc_idx ON service.ads USING GIN(doc);

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE doc @@ to_tsquery('russian','car');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE doc @@ to_tsquery('russian','condition');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE doc @@ to_tsquery('russian','car & condition');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE doc @@ to_tsquery('russian','car | condition');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE doc @@ to_tsquery('russian','!condition');