SELECT
    now() - min(created_at) AS queue_lag,
    count(*) AS ready_count
FROM queue.tasks
WHERE status = 'Ready'
  AND scheduled_at <= now();

SELECT status, priority, count(*)
FROM queue.tasks
GROUP BY status, priority
ORDER BY status, priority;

SELECT
    count(*) AS completed_last_minute,
    round(count(*) / 60.0, 2) AS tasks_per_second
FROM queue.tasks
WHERE status IN ('Completed', 'Failed')
  AND completed_at >= now() - interval '1 minute';

SELECT
    locked_by,
    count(*) AS completed_last_minute,
    round(count(*) / 60.0, 2) AS tasks_per_second
FROM queue.tasks
WHERE status IN ('Completed', 'Failed')
  AND completed_at >= now() - interval '1 minute'
GROUP BY locked_by
ORDER BY locked_by;
