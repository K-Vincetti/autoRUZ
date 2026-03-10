CREATE INDEX gist_ads_period_idx ON service.ads USING GIST(active_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE active_period && tsrange(now(), now() + interval '5 days');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE active_period @> now();

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE active_period <@ tsrange(now()-interval '30 days', now());

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE lower(active_period) > now() - interval '10 days';

EXPLAIN (ANALYZE, BUFFERS)
SELECT ad_id
FROM service.ads
WHERE upper(active_period) < now() + interval '10 days';