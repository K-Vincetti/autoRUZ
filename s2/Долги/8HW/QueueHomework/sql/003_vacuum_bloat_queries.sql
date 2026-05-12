SELECT
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'queue'
  AND relname = 'tasks';

SELECT
    pg_size_pretty(pg_total_relation_size('queue.tasks')) AS total_size,
    pg_size_pretty(pg_relation_size('queue.tasks')) AS table_size;

VACUUM ANALYZE queue.tasks;

SELECT
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'queue'
  AND relname = 'tasks';

SELECT
    pg_size_pretty(pg_total_relation_size('queue.tasks')) AS total_size,
    pg_size_pretty(pg_relation_size('queue.tasks')) AS table_size;
