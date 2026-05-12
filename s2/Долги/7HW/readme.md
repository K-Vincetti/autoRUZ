# ДЗ: Секционирование, репликация секций и шардирование через FDW

## RANGE-секционирование

Проверка данных в секционированной таблице `orders_range`.

![[5357453948207437525.jpg]]

Результат:

|partition|id|created_at|region|amount|
|---|---|---|---|---|
|orders_range_2026_01|1|2026-01-10|Moscow|100|
|orders_range_2026_01|2|2026-01-15|SPB|200|
|orders_range_2026_02|3|2026-02-10|Moscow|300|
|orders_range_2026_02|4|2026-02-20|SPB|400|
|orders_range_2026_03|5|2026-03-05|Moscow|500|
|orders_range_2026_03|6|2026-03-25|SPB|600|

Вывод:

Данные распределены по RANGE-секциям по полю `created_at`.

---

## RANGE: запрос без индекса

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_range  
WHERE created_at = DATE '2026-02-10';

![[5357453948207437565.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_range_2026_02`|
|Индекс|не используется|
|Тип сканирования|`Seq Scan`|
|Execution Time|`0.047 ms`|

Вывод:

PostgreSQL отсекает лишние секции и сканирует только `orders_range_2026_02`.

Индекс не используется, выполняется `Seq Scan`.

---

## RANGE: запрос с индексом

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_range  
WHERE created_at = DATE '2026-02-10'  
AND amount = 300;

![[5357453948207437569.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_range_2026_02`|
|Индекс|используется|
|Индекс в плане|`idx_orders_range_2026_02_amount`|
|Тип сканирования|`Bitmap Heap Scan` + `Bitmap Index Scan`|
|Execution Time|`0.427 ms`|

Вывод:

PostgreSQL использует partition pruning и оставляет только секцию `orders_range_2026_02`.

Индекс по `amount` используется.

---

## LIST-секционирование

Проверка данных в секционированной таблице `orders_list`.

![[5357453948207437576.jpg]]

Результат:

|partition|id|created_at|region|amount|
|---|---|---|---|---|
|orders_list_moscow|1|2026-01-10|Moscow|100|
|orders_list_moscow|2|2026-01-11|Moscow|150|
|orders_list_spb|3|2026-02-10|SPB|200|
|orders_list_spb|4|2026-02-11|SPB|250|
|orders_list_other|5|2026-03-10|Kazan|300|

Вывод:

Данные распределены по LIST-секциям по полю `region`.

---

## LIST: запрос без индекса

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_list  
WHERE region = 'Moscow';

![[5357453948207437577.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_list_moscow`|
|Индекс|не используется|
|Тип сканирования|`Seq Scan`|
|Execution Time|`0.047 ms`|

Вывод:

PostgreSQL отсекает остальные секции и сканирует только `orders_list_moscow`.

Индекс не используется.

---

## LIST: запрос с индексом

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_list  
WHERE region = 'Moscow'  
AND amount = 100;

![[5357453948207437579.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_list_moscow`|
|Индекс|используется|
|Индекс в плане|`idx_orders_list_moscow_amount`|
|Тип сканирования|`Bitmap Heap Scan` + `Bitmap Index Scan`|
|Execution Time|`0.114 ms`|

Вывод:

PostgreSQL использует только секцию `orders_list_moscow`.

Индекс по `amount` используется.

---

## HASH-секционирование

Проверка данных в секционированной таблице `orders_hash`.

![[5357453948207437601.jpg]]

Результат:

|partition|id|created_at|region|amount|
|---|---|---|---|---|
|orders_hash_p2|1|2026-01-01|Moscow|100|
|orders_hash_p0|2|2026-01-02|SPB|200|
|orders_hash_p1|3|2026-01-03|Kazan|300|
|orders_hash_p0|4|2026-01-04|Moscow|400|
|orders_hash_p2|5|2026-01-05|SPB|500|
|orders_hash_p0|6|2026-01-06|Kazan|600|

Вывод:

Данные распределены по HASH-секциям. Конкретная секция выбирается по хешу значения ключа.

---

## HASH: запрос по ключу секционирования

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_hash  
WHERE id = 3;

![[5357453948207437621.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_hash_p1`|
|Индекс|используется|
|Индекс в плане|`orders_hash_p1_pkey`|
|Тип сканирования|`Index Scan`|
|Execution Time|`0.035 ms`|

Вывод:

PostgreSQL определил нужную HASH-секцию и обратился только к `orders_hash_p1`.

Индекс по primary key используется.

---

## HASH: запрос по ключу секционирования и amount

Запрос:

EXPLAIN (ANALYZE, VERBOSE, COSTS, BUFFERS)  
SELECT *  
FROM orders_hash  
WHERE id = 3  
AND amount = 300;

![[5357453948207437623.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Partition pruning|есть|
|Участвует партиций|1|
|Партиция в плане|`orders_hash_p1`|
|Индекс|используется|
|Индекс в плане|`orders_hash_p1_pkey`|
|Тип сканирования|`Index Scan`|
|Дополнительная проверка|`Filter: amount = 300`|
|Execution Time|`0.059 ms`|

Вывод:

Partition pruning есть: участвует только `orders_hash_p1`.

Индекс используется по `id`, а условие по `amount` применяется как фильтр.

---

## Сводка по RANGE / LIST / HASH

|Тип секционирования|Запрос|Partition pruning|Партиций в плане|Индекс|
|---|---|---|---|---|
|RANGE|`created_at = '2026-02-10'`|есть|1|нет|
|RANGE|`created_at = '2026-02-10' AND amount = 300`|есть|1|да|
|LIST|`region = 'Moscow'`|есть|1|нет|
|LIST|`region = 'Moscow' AND amount = 100`|есть|1|да|
|HASH|`id = 3`|есть|1|да|
|HASH|`id = 3 AND amount = 300`|есть|1|да|

Вывод:

Во всех проверенных запросах partition pruning сработал.

Во всех планах участвовала только одна секция.

Индекс использовался там, где условие попадало на проиндексированный столбец.

---

## Физическая репликация и секционирование

Проверка секционированной таблицы.

![[5357453948207437509.jpg]]

Проверка данных по секциям.

![[5357453948207437525.jpg]]

Вывод:

Секционированная таблица состоит из отдельных физических секций.

При физической репликации структура базы копируется на уровне WAL, поэтому секции на реплике сохраняются как обычные объекты PostgreSQL.

---

## Почему физическая репликация “не знает” про секции

Вывод:

Физическая репликация не анализирует таблицы на логическом уровне.

Она передаёт и применяет WAL-записи. Поэтому для неё секции — это просто физические объекты базы данных, изменения которых нужно повторить на standby.

---

## Логическая репликация и publish_via_partition_root

Проверка публикации.

![[5359528026569382207.jpg]]

Результат:

|publication|pubviaroot|
|---|---|
|pub_orders|false|

Вывод:

Параметр `publish_via_partition_root` выключен.

Это означает, что изменения публикуются от имени конкретных секций, а не от имени родительской таблицы.

---

## Проверка INSERT в секционированную таблицу

Запрос:

EXPLAIN (VERBOSE)  
INSERT INTO lab_partition.orders_range  
VALUES (300, '2026-02-10', 'Moscow', 111);

![[5359528026569382254.jpg]]

Результат:

В плане показан `Insert on lab_partition.orders_range`.

Вывод:

Вставка выполняется через родительскую таблицу `orders_range`.

PostgreSQL сам маршрутизирует строку в нужную секцию по значению `created_at`.

---

## Повторная проверка INSERT

Запрос:

EXPLAIN (VERBOSE)  
INSERT INTO lab_partition.orders_range  
VALUES (301, '2026-02-10', 'Moscow', 222);

![[5359528026569382275.jpg]]

Результат:

В плане также показан `Insert on lab_partition.orders_range`.

Вывод:

Поведение повторяется: вставка идёт через родительскую таблицу, а выбор секции делает PostgreSQL.

---

## Проверка отсутствия секционирования при простой копии

Команды:

DROP TABLE IF EXISTS orders_range_copy;

CREATE TABLE orders_range_copy AS  
SELECT * FROM orders_range;

SELECT tableoid::regclass, *  
FROM orders_range_copy;

![[5359528026569382365.jpg]]

Результат:

Все строки находятся в таблице `orders_range_copy`.

Вывод:

При обычном `CREATE TABLE AS SELECT` секционирование не переносится.

Создаётся обычная таблица, а не секционированная структура.

---

## Шардирование через postgres_fdw

## Данные на shard1

Запрос:

SELECT * FROM shard1_orders;

![[5359528026569382283.jpg]]

Результат:

|id|region|amount|
|---|---|---|
|1|Moscow|100|
|2|Moscow|200|

Вывод:

На первом шарде хранятся строки региона `Moscow`.

---

## Данные на shard2

Запрос:

SELECT * FROM shard2_orders;

![[5359528026569382282.jpg]]

Результат:

|id|region|amount|
|---|---|---|
|3|SPB|300|
|4|SPB|400|

Вывод:

На втором шарде хранятся строки региона `SPB`.

---

## Проверка foreign server

Запрос:

SELECT * FROM pg_foreign_server;

![[5359528026569382285.jpg]]

Результат:

Создан foreign server `shard_server`.

Вывод:

FDW-сервер создан. Router может обращаться к внешним таблицам через postgres_fdw.

---

## Проверка foreign table для shard1

Запрос:

SELECT * FROM shard1_orders_fdw;

![[5359528026569382292.jpg]]

Результат:

|id|region|amount|
|---|---|---|
|1|Moscow|100|
|2|Moscow|200|

Вывод:

Данные первого шарда доступны через foreign table `shard1_orders_fdw`.

---

## Проверка foreign table для shard2

Запрос:

SELECT * FROM shard2_orders_fdw;

![[5359528026569382293.jpg]]

Результат:

|id|region|amount|
|---|---|---|
|3|SPB|300|
|4|SPB|400|

Вывод:

Данные второго шарда доступны через foreign table `shard2_orders_fdw`.

---

## Проверка router-таблицы

Запрос:

SELECT * FROM orders_router;

![[5359528026569382294.jpg]]

Результат:

|id|region|amount|
|---|---|---|
|1|Moscow|100|
|2|Moscow|200|
|3|SPB|300|
|4|SPB|400|

Вывод:

Router объединяет данные с двух шардов.

---

## План запроса на все данные через router

Запрос:

EXPLAIN (VERBOSE)  
SELECT * FROM orders_router;

![[5359528026569382297.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Тип плана|`Append`|
|Источник 1|`Foreign Scan on shard1_orders_fdw`|
|Источник 2|`Foreign Scan on shard2_orders_fdw`|
|Remote SQL shard1|`SELECT id, region, amount FROM lab_partition.shard1_orders`|
|Remote SQL shard2|`SELECT id, region, amount FROM lab_partition.shard2_orders`|

Вывод:

Запрос на все данные обращается к обоим шардам.

В плане участвуют две foreign table.

---

## План запроса с фильтром по региону через router

Запрос:

EXPLAIN (VERBOSE)  
SELECT *  
FROM orders_router  
WHERE region = 'Moscow';

![[5359528026569382298.jpg]]

Результат:

|Параметр|Значение|
|---|---|
|Тип плана|`Append`|
|Источник 1|`Foreign Scan on shard1_orders_fdw`|
|Источник 2|`Foreign Scan on shard2_orders_fdw`|
|Фильтр|`region = 'Moscow'`|
|Remote SQL|фильтр передан на удалённые таблицы|

Вывод:

Фильтр `region = 'Moscow'` был передан в remote SQL.

При этом в плане всё равно участвуют оба шарда.

---

## Итоги

RANGE-секционирование проверено: partition pruning есть, в плане участвует одна секция.

LIST-секционирование проверено: partition pruning есть, в плане участвует одна секция.

HASH-секционирование проверено: partition pruning есть, в плане участвует одна секция.

Индексы используются там, где условие подходит под индекс.

При физической репликации секционирование сохраняется, потому что репликация работает через WAL.

Логическая репликация не переносит DDL автоматически.

`publish_via_partition_root = false` означает публикацию изменений от имени конкретных секций.

Через `postgres_fdw` реализованы два шарда и один router.

Запрос на все данные через router обращается к обоим шардам.

Запрос с фильтром по региону передаёт фильтр на удалённые таблицы, но в плане всё равно участвуют оба шарда.