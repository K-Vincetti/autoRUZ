
# ДЗ: Индексы, EXPLAIN, ANALYZE, BUFFERS

## 1. Таблица

Для выполнения задания использовалась таблица:

```
service.ads
```

В таблице есть следующие поля:

- `adid`
- `sellerid`
- `transportid`
- `headertext`
- `description`
- `costof`
- `publicationdate`
- `status`

---

## 3. Используемые запросы

### Запрос 1 — диапазон по стоимости

```
EXPLAIN (ANALYZE, BUFFERS)SELECT count(*) FROM service.adsWHERE costof > 500000 AND costof < 2000000;
```

### Запрос 2 — равенство по статусу

```
EXPLAIN (ANALYZE, BUFFERS)SELECT count(*) FROM service.adsWHERE status = 'active';
```

### Запрос 3 — LIKE с поиском внутри строки

```
EXPLAIN (ANALYZE, BUFFERS)SELECT count(*) FROM service.adsWHERE headertext LIKE '%car%';
```

### Запрос 4 — LIKE по началу строки

```
EXPLAIN (ANALYZE, BUFFERS)SELECT count(*) FROM service.adsWHERE headertext LIKE 'Selling%';
```

### Запрос 5 — IN по продавцам

```
EXPLAIN (ANALYZE, BUFFERS)SELECT count(*) FROM service.adsWHERE sellerid IN (1,2,3,4,5,6,7,8,9,10);
```

---

## 4. Результаты без индексов

Перед выполнением запросов индексы были удалены, после этого была обновлена статистика таблицы.

```
DROP INDEX IF EXISTS service.hw_ads_costof_btree;DROP INDEX IF EXISTS service.hw_ads_status_btree;DROP INDEX IF EXISTS service.hw_ads_headertext_btree;DROP INDEX IF EXISTS service.hw_ads_sellerid_btree;DROP INDEX IF EXISTS service.hw_ads_status_hash;DROP INDEX IF EXISTS service.hw_ads_sellerid_hash;DROP INDEX IF EXISTS service.hw_ads_seller_status_btree;ANALYZE service.ads;
```

### 4.1. Запрос 1 без индекса

![[no_index_price_range.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `52.853 ms`

Описание:

Для условия по диапазону `costof > 500000 AND costof < 2000000` PostgreSQL использовал параллельное последовательное сканирование таблицы. Так как индекса нет, таблица просматривается целиком.

---

### 4.2. Запрос 2 без индекса

![[no_index_status_equal.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `47.083 ms`

Описание:

Для условия `status = 'active'` без индекса PostgreSQL также использовал `Parallel Seq Scan`.

---

### 4.3. Запрос 3 без индекса

![[no_index_like_contains.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `48.307 ms`

Описание:

Запрос с `LIKE '%car%'` выполнялся последовательным сканированием. PostgreSQL проверял значения поля `headertext` построчно.

---

### 4.4. Запрос 4 без индекса

![[no_index_like_prefix.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `49.115 ms`

Описание:

Запрос с `LIKE 'Selling%'` также выполнялся через `Parallel Seq Scan`, так как подходящий индекс отсутствовал.

---

### 4.5. Запрос 5 без индекса

![[no_index_seller_in.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `45.273 ms`

Описание:

Для условия `sellerid IN (...)` без индекса PostgreSQL выполнил последовательное сканирование таблицы.

---

## 5. Результаты с B-tree индексами

Были созданы B-tree индексы.

```
DROP INDEX IF EXISTS service.hw_ads_costof_btree;DROP INDEX IF EXISTS service.hw_ads_status_btree;DROP INDEX IF EXISTS service.hw_ads_headertext_btree;DROP INDEX IF EXISTS service.hw_ads_sellerid_btree;DROP INDEX IF EXISTS service.hw_ads_status_hash;DROP INDEX IF EXISTS service.hw_ads_sellerid_hash;DROP INDEX IF EXISTS service.hw_ads_seller_status_btree;CREATE INDEX hw_ads_costof_btreeON service.ads USING btree(costof);CREATE INDEX hw_ads_status_btreeON service.ads USING btree(status);CREATE INDEX hw_ads_headertext_btreeON service.ads USING btree(headertext);CREATE INDEX hw_ads_sellerid_btreeON service.ads USING btree(sellerid);ANALYZE service.ads;
```

### 5.1. Запрос 1 с B-tree индексом

![[btree_costof_range.png]]

Результат:

- Тип сканирования: `Index Only Scan`
- Использованный индекс: `hw_ads_costof_btree`
- Index Cond: `(costof > 500000) AND (costof < 2000000)`
- Heap Fetches: `0`
- Buffers: `shared hit=4 read=136`
- Execution Time: `10.195 ms`

Описание:

B-tree индекс по `costof` применился. PostgreSQL использовал `Index Only Scan`, то есть смог выполнить запрос по индексу без чтения строк из основной таблицы.

---

### 5.2. Запрос 2 с B-tree индексом

![[btree_status_active.png]]

Результат:

- Тип сканирования: `Index Only Scan`
- Использованный индекс: `hw_ads_status_btree`
- Index Cond: `status = 'active'`
- Heap Fetches: `0`
- Buffers: `shared hit=1 read=86`
- Execution Time: `18.918 ms`

Описание:

B-tree индекс по `status` применился для условия равенства. PostgreSQL использовал `Index Only Scan`.

---

### 5.3. Запрос 3 с B-tree индексом

![[btree_like_contains.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `92.972 ms`

Описание:

Для `LIKE '%car%'` B-tree индекс не применился. Это связано с тем, что шаблон начинается с `%`, поэтому поиск идёт не по началу строки, а по подстроке внутри текста.

---

### 5.4. Запрос 4 с B-tree индексом

![[btree_like_prefix.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `94.289 ms`

Описание:

Для `LIKE 'Selling%'` PostgreSQL также выбрал `Parallel Seq Scan`. Несмотря на наличие B-tree индекса по `headertext`, планировщик не использовал его и выбрал последовательное сканирование.

---

### 5.5. Запрос 5 с B-tree индексом

![[btree_sellerid_in.png]]

Результат:

- Тип сканирования: `Index Only Scan`
- Использованный индекс: `hw_ads_sellerid_btree`
- Index Cond: `sellerid = ANY ('{1,2,3,4,5,6,7,8,9,10}'::integer[])`
- Heap Fetches: `0`
- Buffers: `shared hit=1 read=128`
- Execution Time: `29.370 ms`

Описание:

B-tree индекс по `sellerid` применился для условия `IN`. PostgreSQL использовал `Index Only Scan`.

---

## 6. Результаты с Hash индексами

Были созданы Hash индексы.

```
DROP INDEX IF EXISTS service.hw_ads_costof_btree;DROP INDEX IF EXISTS service.hw_ads_status_btree;DROP INDEX IF EXISTS service.hw_ads_headertext_btree;DROP INDEX IF EXISTS service.hw_ads_sellerid_btree;DROP INDEX IF EXISTS service.hw_ads_status_hash;DROP INDEX IF EXISTS service.hw_ads_sellerid_hash;DROP INDEX IF EXISTS service.hw_ads_seller_status_btree;CREATE INDEX hw_ads_status_hashON service.ads USING hash(status);CREATE INDEX hw_ads_sellerid_hashON service.ads USING hash(sellerid);ANALYZE service.ads;
```

### 6.1. Запрос 1 с Hash индексом

![[hash_costof_range.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `90.978 ms`

Описание:

Hash индекс не применился, так как запрос использует диапазонное условие `>` и `<`. Hash индекс подходит только для равенства.

---

### 6.2. Запрос 2 с Hash индексом

![[hash_status_active.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `79.521 ms`

Описание:

Хотя Hash индекс подходит для равенства, PostgreSQL выбрал `Parallel Seq Scan`. Это означает, что планировщик посчитал последовательное сканирование более выгодным для данного запроса.

---

### 6.3. Запрос 3 с Hash индексом

![[hash_like_contains.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `71.291 ms`

Описание:

Hash индекс не применился, так как он не используется для условий `LIKE`.

---

### 6.4. Запрос 4 с Hash индексом

![[hash_like_prefix.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `70.327 ms`

Описание:

Hash индекс не применился, так как условие использует `LIKE`, а Hash индекс предназначен для поиска по равенству.

---

### 6.5. Запрос 5 с Hash индексом

![[hash_sellerid_in.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `66.183 ms`

Описание:

Для `sellerid IN (...)` Hash индекс не был использован. PostgreSQL выбрал `Parallel Seq Scan`.

---

## 7. Результаты с составным индексом

Был создан составной B-tree индекс по полям `sellerid` и `status`.

```
DROP INDEX IF EXISTS service.hw_ads_costof_btree;DROP INDEX IF EXISTS service.hw_ads_status_btree;DROP INDEX IF EXISTS service.hw_ads_headertext_btree;DROP INDEX IF EXISTS service.hw_ads_sellerid_btree;DROP INDEX IF EXISTS service.hw_ads_status_hash;DROP INDEX IF EXISTS service.hw_ads_sellerid_hash;DROP INDEX IF EXISTS service.hw_ads_seller_status_btree;CREATE INDEX hw_ads_seller_status_btreeON service.ads USING btree(sellerid, status);ANALYZE service.ads;
```

### 7.1. Запрос 1 с составным индексом

![[composite_costof_range.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `86.955 ms`

Описание:

Составной индекс `(sellerid, status)` не подходит для условия по `costof`, поэтому PostgreSQL использовал `Parallel Seq Scan`.

---

### 7.2. Запрос 2 с составным индексом

![[composite_status_active.png]]

Результат:

- Тип сканирования: `Index Only Scan`
- Использованный индекс: `hw_ads_seller_status_btree`
- Index Cond: `status = 'active'`
- Heap Fetches: `0`
- Buffers: `shared hit=1 read=130`
- Execution Time: `16.730 ms`

Описание:

PostgreSQL использовал составной индекс и выполнил `Index Only Scan`.

---

### 7.3. Запрос 3 с составным индексом

![[composite_like_contains.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `184.108 ms`

Описание:

Составной индекс не применился, так как запрос выполняется по полю `headertext`, а индекс создан по полям `sellerid` и `status`.

---

### 7.4. Запрос 4 с составным индексом

![[composite_like_prefix.png]]

Результат:

- Тип сканирования: `Parallel Seq Scan`
- Buffers: `shared hit=3732`
- Execution Time: `72.454 ms`

Описание:

Составной индекс не применился, так как условие использует поле `headertext`, которого нет в составном индексе.

---

### 7.5. Запрос 5 с составным индексом

![[composite_sellerid_in.png]]

Результат:

- Тип сканирования: `Index Only Scan`
- Использованный индекс: `hw_ads_seller_status_btree`
- Index Cond: `sellerid = ANY ('{1,2,3,4,5,6,7,8,9,10}'::integer[])`
- Heap Fetches: `0`
- Buffers: `shared hit=131`
- Execution Time: `31.274 ms`

Описание:

Составной индекс применился, так как первое поле индекса — `sellerid`, и запрос фильтрует данные по этому полю.

## 8. Сравнительная таблица результатов

| №   | Условие                                | Без индекса                                         | B-tree                                                  | Hash                                                | Составной индекс                                        |
| --- | -------------------------------------- | --------------------------------------------------- | ------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| 1   | `costof > 500000 AND costof < 2000000` | `Parallel Seq Scan`, `52.853 ms`, `shared hit=3732` | `Index Only Scan`, `10.195 ms`, `shared hit=4 read=136` | `Parallel Seq Scan`, `90.978 ms`, `shared hit=3732` | `Parallel Seq Scan`, `86.955 ms`, `shared hit=3732`     |
| 2   | `status = 'active'`                    | `Parallel Seq Scan`, `47.083 ms`, `shared hit=3732` | `Index Only Scan`, `18.918 ms`, `shared hit=1 read=86`  | `Parallel Seq Scan`, `79.521 ms`, `shared hit=3732` | `Index Only Scan`, `16.730 ms`, `shared hit=1 read=130` |
| 3   | `headertext LIKE '%car%'`              | `Parallel Seq Scan`, `48.307 ms`, `shared hit=3732` | `Parallel Seq Scan`, `92.972 ms`, `shared hit=3732`     | `Parallel Seq Scan`, `71.291 ms`, `shared hit=3732` | `Parallel Seq Scan`, `184.108 ms`, `shared hit=3732`    |
| 4   | `headertext LIKE 'Selling%'`           | `Parallel Seq Scan`, `49.115 ms`, `shared hit=3732` | `Parallel Seq Scan`, `94.289 ms`, `shared hit=3732`     | `Parallel Seq Scan`, `70.327 ms`, `shared hit=3732` | `Parallel Seq Scan`, `72.454 ms`, `shared hit=3732`     |
| 5   | `sellerid IN (...)`                    | `Parallel Seq Scan`, `45.273 ms`, `shared hit=3732` | `Index Only Scan`, `29.370 ms`, `shared hit=1 read=128` | `Parallel Seq Scan`, `66.183 ms`, `shared hit=3732` | `Index Only Scan`, `31.274 ms`, `shared hit=131`        |