# ДЗ: Репликация PostgreSQL

## Архитектура physical streaming replication

![[physical_replication_architecture.png]]

Схема:

- `primary` — основной PostgreSQL instance, порт `5432`
- `replica1` — standby-реплика, порт `5433`
- `replica2` — standby-реплика, порт `5434`

Вывод:

Развёрнута архитектура из одного primary-сервера и двух standby-реплик. Репликация настроена от `primary` к `replica1` и `replica2`.

---

## Проверка wal_level для physical replication

Команда:

docker exec -it primary psql -U postgres -d postgres -c "SHOW wal_level;"

![[Screenshot 2026-03-24 152350.png]]

Результат:

|Параметр|Значение|
|---|---|
|`wal_level`|`replica`|

Вывод:

Для physical streaming replication установлен `wal_level = replica`.

---

## Проверка pg_hba.conf

Команда:

docker exec -it primary bash -lc "tail -n 5 $PGDATA/pg_hba.conf"

![[Screenshot 2026-03-24 152632.png]]

Результат:

В `pg_hba.conf` разрешены подключения для репликации.

Вывод:

Primary разрешает подключения для репликации, поэтому standby-инстансы могут подключаться к нему.

---

## Проверка данных на primary

Команда:

SELECT * FROM test_replication;

![[Screenshot 2026-03-24 151351.png]]

Результат:

|id|data|
|---|---|
|1|`first row`|
|2|`second row`|

Вывод:

На primary в таблице `test_replication` есть две строки.

---

## Проверка данных на replica1

Команда:

docker exec -it replica1 psql -U postgres -d postgres

SELECT * FROM test_replication;

![[Screenshot 2026-03-24 151541.png]]

Результат:

|id|data|
|---|---|
|1|`first row`|
|2|`second row`|

Вывод:

На `replica1` данные появились. Репликация с primary на первую реплику работает.

---

## Проверка данных на replica2

Команда:

docker exec -it replica2 psql -U postgres -d postgres

SELECT * FROM test_replication;

![[Screenshot 2026-03-24 151650.png]]

Результат:

|id|data|
|---|---|
|1|`first row`|
|2|`second row`|

Вывод:

На `replica2` данные также появились. Репликация с primary на вторую реплику работает.

---

## Попытка INSERT на реплике

Команда:

INSERT INTO test_replication (data) VALUES ('should fail');

![[Screenshot 2026-03-24 151750.png]]

Результат:

ERROR: cannot execute INSERT in a read-only transaction

Вывод:

На physical standby-реплике нельзя выполнять `INSERT`, потому что реплика работает в режиме read-only.

---

## Нагрузка INSERT для проверки replication lag

Команда:

INSERT INTO load_test (payload)  
SELECT md5(random()::text)  
FROM generate_series(1, 100000);

SELECT count(*) FROM load_test;

![[Screenshot 2026-03-24 152148.png]]

Результат:

|count|
|---|
|100000|

Вывод:

На primary была создана нагрузка: вставлено `100000` строк в таблицу `load_test`.

---

## Проверка replication lag

Команда:

SELECT pid, application_name, state, sync_state, write_lag, flush_lag, replay_lag  
FROM pg_stat_replication;

![[Screenshot 2026-03-24 152213.png]]

Результат:

|application_name|state|sync_state|
|---|---|---|
|walreceiver|streaming|async|
|walreceiver|streaming|async|

Вывод:

Обе реплики находятся в состоянии `streaming`.

Репликация работает в асинхронном режиме: `sync_state = async`.

Значения `write_lag`, `flush_lag`, `replay_lag` не отображены, значит на момент проверки заметного lag не было.

---

# Logical replication

## Архитектура logical replication

![[logical_replication_architecture.png]]

Схема:

- `publisher` — PostgreSQL на порту `5432`
- `subscriber` — PostgreSQL на порту `5433`
- между ними настроены `PUBLICATION` и `SUBSCRIPTION`

Вывод:

Логическая репликация настроена по схеме publisher → subscriber.

---

## Проверка wal_level для logical replication

Команда:

docker exec -it primary psql -U postgres -d postgres -c "SHOW wal_level;"

![[Screenshot 2026-03-24 152442.png]]

Результат:

|Параметр|Значение|
|---|---|
|`wal_level`|`logical`|

Вывод:

Для logical replication установлен `wal_level = logical`.

---

## Создание таблицы на subscriber

Команда:

CREATE TABLE logical_test (  
id SERIAL PRIMARY KEY,  
data TEXT  
);

![[Screenshot 2026-03-24 153048.png]]

Результат:

CREATE TABLE

Вывод:

Таблица `logical_test` была создана на subscriber.

Для logical replication структура таблицы должна существовать на subscriber заранее.

---

## Создание publication

Команда:

CREATE PUBLICATION my_publication FOR TABLE logical_test;

\dRp+

![[Screenshot 2026-03-24 153156.png]]

Результат:

Publication `my_publication` создана для таблицы `public.logical_test`.

Вывод:

На publisher создана публикация `my_publication`.

В публикацию добавлена таблица `logical_test`.

---

## Создание subscription

Команда:

CREATE SUBSCRIPTION my_subscription ...

![[Screenshot 2026-03-24 154739.png]]

Результат:

NOTICE: created replication slot "my_subscription" on publisher

CREATE SUBSCRIPTION

Вывод:

На subscriber создана подписка `my_subscription`.

Также был создан replication slot `my_subscription` на publisher.

---

## Проверка репликации INSERT

Команды на publisher:

INSERT INTO logical_test (data) VALUES ('row 1');

INSERT INTO logical_test (data) VALUES ('row 2');

SELECT * FROM logical_test;

![[Screenshot 2026-03-24 155021.png]]

Результат на publisher:

|id|data|
|---|---|
|1|`row 1`|
|2|`row 2`|

Вывод:

На publisher были вставлены две строки.

Данные успешно появились в таблице `logical_test`.

---

## Проверка UPDATE и DELETE в logical replication

Команды:

UPDATE logical_test SET data = 'row 1 updated' WHERE id = 1;

DELETE FROM logical_test WHERE id = 2;

SELECT * FROM logical_test;

![[Screenshot 2026-03-24 155501.png]]

Результат:

|id|data|
|---|---|
|1|`row 1 updated`|

Вывод:

После `UPDATE` строка с `id = 1` изменилась.

После `DELETE` строка с `id = 2` была удалена.

На subscriber осталась одна строка: `row 1 updated`.

Данные реплицируются.

---

## Проверка таблицы без Primary Key

Команды:

CREATE TABLE no_pk_test (  
data TEXT  
);

CREATE TABLE no_pk_test (  
data TEXT  
);

ALTER PUBLICATION my_publication ADD TABLE no_pk_test;

![[Screenshot 2026-03-24 155614.png]]

Результат:

CREATE TABLE

CREATE TABLE

ALTER PUBLICATION

Вывод:

Таблица `no_pk_test` без primary key была создана на publisher и subscriber.

После этого таблица была добавлена в publication.

---

## Проверка UPDATE для таблицы без Primary Key

Команды:

INSERT INTO no_pk_test (data) VALUES ('row1');

INSERT INTO no_pk_test (data) VALUES ('row2');

UPDATE no_pk_test SET data = 'updated';

![[Screenshot 2026-03-24 155647.png]]

Результат:

ERROR: cannot update table "no_pk_test" because it does not have a replica identity and publishes updates

HINT: To enable updating the table, set REPLICA IDENTITY using ALTER TABLE.

Вывод:

`INSERT` для таблицы без primary key выполнился.

`UPDATE` не выполнился, потому что у таблицы нет replica identity.

Для репликации UPDATE/DELETE таблице нужен primary key или `REPLICA IDENTITY FULL`.

---

## Настройка REPLICA IDENTITY FULL

Команды:

ALTER TABLE no_pk_test REPLICA IDENTITY FULL;

UPDATE no_pk_test SET data = 'updated_after_identity';

SELECT * FROM no_pk_test;

![[Screenshot 2026-03-24 155718.png]]

Результат на publisher:

|data|
|---|
|`updated_after_identity`|
|`updated_after_identity`|

Результат на subscriber:

|data|
|---|

Вывод:

После `REPLICA IDENTITY FULL` команда `UPDATE` на publisher выполнилась.

На subscriber строки в таблице `no_pk_test` не появились, потому что начальные данные этой таблицы не были синхронизированы на момент проверки.

---

## Проверка replication slot

Команда:

SELECT slot_name, plugin, slot_type, active  
FROM pg_replication_slots;

![[Screenshot 2026-03-24 155809.png]]

Результат:

|slot_name|plugin|slot_type|active|
|---|---|---|---|
|my_subscription|pgoutput|logical|t|

Вывод:

Replication slot `my_subscription` активен.

Тип слота — `logical`.

---

## Проверка статуса subscription

Команда:

SELECT * FROM pg_stat_subscription;

![[Screenshot 2026-03-24 155853.png]]

Результат:

|subid|subname|pid|received_lsn|latest_end_lsn|
|---|---|---|---|---|
|16407|my_subscription|1126|0/D143078|0/D143078|

Вывод:

Подписка `my_subscription` активна.

`received_lsn` и `latest_end_lsn` совпадают, значит subscriber получил изменения до актуальной позиции.

---

## DDL в logical replication

Вывод:

DDL-команды не реплицируются автоматически.

Это видно по тому, что таблицу `logical_test` нужно было создавать на subscriber отдельно перед настройкой подписки.

Для logical replication структура таблиц должна быть подготовлена на subscriber заранее.

---

## pg_dump и pg_restore для logical replication

Вывод:

`pg_dump` и `pg_restore` могут использоваться для подготовки subscriber.

Через них можно заранее перенести структуру таблиц и начальные данные, а затем настроить `SUBSCRIPTION`, чтобы дальше реплицировались новые изменения.

Это удобно, потому что logical replication не переносит DDL автоматически.

---

## Краткие выводы

Physical streaming replication настроена между `primary`, `replica1` и `replica2`.

Данные, вставленные на primary, появились на обеих репликах.

На physical standby-реплике нельзя выполнять `INSERT`, потому что она read-only.

Replication lag проверялся через `pg_stat_replication`.

Logical replication настроена через `PUBLICATION` и `SUBSCRIPTION`.

Данные из `logical_test` реплицировались с publisher на subscriber.

DDL не реплицируется автоматически.

Для таблицы без primary key `UPDATE` не работает без настройки `REPLICA IDENTITY`.

Replication slot и subscription находятся в активном состоянии.