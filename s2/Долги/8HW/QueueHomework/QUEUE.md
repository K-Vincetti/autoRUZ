# ДЗ: PostgreSQL Queue

## Схема таблицы tasks

Скриншот:

![[tasks_table_structure.png]]

Кратко:

таблица `queue.tasks` хранит задачи очереди;
статусы: `Ready`, `Running`, `Completed`, `Failed`;
есть `priority`, `attempts`, `scheduled_at`, `locked_by`.

Вывод:

Таблица подходит для хранения очереди задач.

## Индексы

![[tasks_indexes.png]]

Вывод:

Индексы позволяют быстро находить задачи в статусе `Ready` с учётом `priority` и `scheduled_at`.

## Producer

![[producer_console.png]]

![[tasks_after_producer.png]]

Вывод:

Producer создаёт задачи.
Распределение приоритетов соответствует условию: большинство задач обычные, часть задач критические.

## Workers

![[worker1_console.png]]

![[worker2_console.png]]

![[tasks_with_workers_statuses.png]]

Вывод:

Два воркера конкурентно обрабатывают задачи.

## Конкуренция воркеров

![[workers_processed_count.png]]

![[last_processed_tasks.png]]

Вывод:

Задачи распределяются между `worker-1` и `worker-2`.

## Queue lag

![[monitor_queue_lag.png]]

![[sql_queue_lag.png]]

Вывод:

При высокой нагрузке очередь начинает расти.
Lag показывает, сколько времени самая старая `Ready`-задача ждёт обработки.

## Throughput

![[sql_throughput_total.png]]

![[sql_throughput_by_worker.png]]

Вывод:

Throughput показывает, сколько задач в секунду суммарно обрабатывают воркеры.

## Priority

![[priority_avg_wait_time.png]]

![[priority_last_completed_tasks.png]]

Вывод:

Задачи с `priority = 100` выбираются раньше обычных задач с `priority = 0`.

## Retry

![[retry_attempts.png]]

Вывод:

При ошибке `attempts` увеличивается, а `scheduled_at` переносится в будущее.

## LISTEN / NOTIFY

![[listen_notify_worker.png]]

![[listen_notify_producer.png]]

Вывод:

Producer отправляет `NOTIFY`, worker получает уведомление через `LISTEN`.
`LISTEN/NOTIFY` не хранит задачи, а только будит воркера. Сама задача хранится в таблице `queue.tasks`.

## VACUUM / Bloat

![[bloat_before_vacuum.png]]

![[vacuum_analyze_result.png]]

![[bloat_after_vacuum.png]]

Вывод:

После частых обновлений в таблице появляются `dead tuples`.
`VACUUM ANALYZE` выполняет очистку и обновляет статистику.

## Краткие итоги

PostgreSQL можно использовать как очередь задач.

Producer создаёт задачи в рамках транзакции вместе с бизнес-логикой.

Два `worker`-процесса безопасно конкурируют за задачи через `FOR UPDATE SKIP LOCKED`.

Priority позволяет выполнять критические задачи раньше обычных.

Retry переносит неудачные задачи на повторное выполнение.

`LISTEN / NOTIFY` уменьшает постоянный polling.

`VACUUM` нужен из-за частых `UPDATE` и возможного bloat.
