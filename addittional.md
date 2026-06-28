QUERY PLAN                                                                                                             |
-----------------------------------------------------------------------------------------------------------------------+
Hash Join  (cost=27.09..41.32 rows=7 width=274) (actual time=0.865..0.873 rows=2.00 loops=1)                           |
  Hash Cond: (p.product_id = oi.product_id)                                                                            |
  Buffers: shared hit=2                                                                                                |
  ->  Seq Scan on products p  (cost=0.00..13.00 rows=300 width=222) (actual time=0.036..0.037 rows=6.00 loops=1)       |
        Buffers: shared hit=1                                                                                          |
  ->  Hash  (cost=27.00..27.00 rows=7 width=28) (actual time=0.041..0.044 rows=2.00 loops=1)                           |
        Buckets: 1024  Batches: 1  Memory Usage: 9kB                                                                   |
        Buffers: shared hit=1                                                                                          |
        ->  Seq Scan on order_items oi  (cost=0.00..27.00 rows=7 width=28) (actual time=0.018..0.019 rows=2.00 loops=1)|
              Filter: (order_id = 1)                                                                                   |
              Rows Removed by Filter: 2                                                                                |
              Buffers: shared hit=1                                                                                    |
Planning:                                                                                                              |
  Buffers: shared hit=9                                                                                                |
Planning Time: 1.343 ms                                                                                                |
Execution Time: 1.730 ms                                                                                               |



PostgreSQL виконує цей запит за допомогою обʼєднання таблиць Hash Join.
За допомогою послідовного сканування (Seq scan) проходить по усій таблиці order_items та шукає товар індексу 1. Створює тимчасову хеш таблицю, куди додає попередньо знайдені дані. Потім робить послідовне сканування на таблиці products. Потім порівнює отримані дані з тимчасовою хеш таблицею за умовою p.product_id = oi.product_id, щоб миттєво знайти збіги та видати результат.
