# QALOAD core db issue

## Symptoms 
- Overall
  - QALOAD test failed randomly because of high error rate and high latency
  - QALOAD test behave very differently with same config and same traffic, reflected in the latency of requests as well as db performance
- Proofs
  - performance of API varies between two runs of same traffic
    - ![](performance%20of%20API%20varies%20between%20two%20runs%20of%20same%20traffic.png)
    - APIs with more than 15s latency, causing the build to fail.

## Findings 

The difference in db performance reflected in some db metrics.


### Wait event `wait/synch/rwlock/innodb/fts_cache_rw_lock` cost most of time

- Wait event `wait/synch/rwlock/innodb/fts_cache_rw_lock` contributes to most of the difference between two runs
  - ![](wait%20event%20contributes%20to%20most%20of%20the%20vcpu%20difference%20between%20two%20runs.png)
  - Based on the mysql documentation on [Wait Instrument Elements Naming Conventions](https://dev.mysql.com/doc/refman/5.6/en/performance-schema-instrument-naming.html#performance-schema-wait-instrument-elements), we know that it's related to wait events on read write locks of full-text-search cache.
    - [InnoDB Full-Text Index Cache](https://dev.mysql.com/doc/refman/5.6/en/innodb-fulltext-index.html#innodb-fulltext-index-cache)
      > When a document is inserted, it is tokenized, and the individual words and associated data are inserted into the full-text index. This process, even for small documents, can result in numerous small insertions into the auxiliary index tables, making concurrent access to these tables a point of contention. To avoid this problem, InnoDB uses a full-text index cache to temporarily cache index table insertions for recently inserted rows. This in-memory cache structure holds insertions until the cache is full and then batch flushes them to disk (to the auxiliary index tables). You can query the INFORMATION_SCHEMA.INNODB_FT_INDEX_CACHE table to view tokenized data for recently inserted rows.

      > The innodb_ft_cache_size variable is used to configure the full-text index cache size (on a per-table basis), which affects how often the full-text index cache is flushed. You can also define a global full-text index cache size limit for all tables in a given instance using the innodb_ft_total_cache_size variable.
    - [The INFORMATION_SCHEMA INNODB_FT_INDEX_CACHE Table](https://dev.mysql.com/doc/refman/5.6/en/information-schema-innodb-ft-index-cache-table.html)
      > The INNODB_FT_INDEX_CACHE table provides token information about newly inserted rows in a FULLTEXT index. To avoid expensive index reorganization during DML operations, the information about newly indexed words is stored separately, and combined with the main search index only when OPTIMIZE TABLE is run, when the server is shut down, or when the cache size exceeds a limit defined by the innodb_ft_cache_size or innodb_ft_total_cache_size system variable.


### Metrics indicating different db performance
- Another two db metrics behaving very differently between good and bad runs are:
  - `db.Cache.innodb_buffer_pool_read_requests.avg`
  - `db.Cache.innodb_buffer_pool_hits.avg`
- Patterns identified
  - When they are at high level, the db performance are degraded
  - When they are at low level, the db performance are normal. Core load tests run during this time will pass.
    - Different db performance with these two metrics at different level.
    - ![](db%20metrics%20indicating%20a%20workload%20going%20on.png)
  - They does not increase as soon as the env starts.
    - ![](They%20does%20not%20increase%20as%20soon%20as%20the%20env%20starts..png)
  - They remain at a high level after the first warm up and will last for more than two hours, some times more than 4 hours.
    - ![](they%20last%20for%20hours.png)
      - In this case those two metics remained at high level during run 1, 2 and 3, all of which had bad performance. And when they dropped to lower level, we triggered run 4, and the performance is much better.



### Next steps
Try to find out what's the processing running. Many different approaches have been tried, but couldn't see the secret workload. Also getting errors about permissions.

```
mysql> SET GLOBAL innodb_ft_aux_table = 'paylater/order_detail';
ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER privilege(s) for this operation

```




### Some debug outputs when the secret workload is running

- Wait events group by source
  ```
  mysql> SELECT count(*), SOURCE        FROM performance_schema.events_waits_current group by SOURCE;
  +----------+-----------------------+
  | count(*) | SOURCE                |
  +----------+-----------------------+
  |        1 | binlog.cc:6439        |
  |        1 | dict0dict.cc:221      |
  |        1 | file_as_table.cc:3659 |
  |        1 | grover_repl.cc:2556   |
  |        1 | ibuf0ibuf.cc:2846     |
  |        1 | lock0newlock.cc:6180  |
  |        1 | lock0newwait.cc:792   |
  |        1 | log0log.ic:419        |
  |        1 | mysqld.cc:4577        |
  |        1 | mysqld.cc:9830        |
  |        2 | my_thr_init.c:359     |
  |       39 | os0sync.cc:899        |
  |     1121 | sql_class.cc:5689     |
  |        1 | sql_class.h:2234      |
  |        1 | sql_plugin.cc:796     |
  |        1 | srv0srv.cc:2852       |
  |        1 | trx0trx.cc:741        |
  +----------+-----------------------+
  17 rows in set (0.00 sec)
  ```

- Wait events group by event name
  ```
  mysql> SELECT count(*), EVENT_NAME     FROM performance_schema.events_waits_current group by EVENT_NAME;
  +----------+-------------------------------------------------+
  | count(*) | EVENT_NAME                                      |
  +----------+-------------------------------------------------+
  |        1 | wait/synch/cond/sql/COND_server_started         |
  |        1 | wait/synch/cond/sql/FILE_AS_TABLE::cond_request |
  |        1 | wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond  |
  |        1 | wait/synch/mutex/innodb/fil_system_mutex        |
  |        1 | wait/synch/mutex/innodb/ibuf_mutex              |
  |        1 | wait/synch/mutex/innodb/lock_wait_mutex         |
  |       39 | wait/synch/mutex/innodb/os_mutex                |
  |        2 | wait/synch/mutex/innodb/trx_sys_mutex           |
  |        2 | wait/synch/mutex/mysys/THR_LOCK_threads         |
  |        1 | wait/synch/mutex/sql/LOCK_plugin                |
  |        1 | wait/synch/mutex/sql/LOCK_thread_count          |
  |        1 | wait/synch/mutex/sql/SERVER_THREAD::LOCK_sync   |
  |     1102 | wait/synch/mutex/sql/THD::LOCK_thd_data         |
  |        1 | wait/synch/rwlock/innodb/dict sys RW lock       |
  |        1 | wait/synch/rwlock/innodb/trx_purge_latch        |
  +----------+-------------------------------------------------+
  15 rows in set (0.01 sec)
  ```

- Most time consuming sql

  ```
  mysql> SELECT count(*), SQL_TEXT, sum(TIMER_WAIT) as sum FROM performance_schema.events_statements_current group by SQL_TEXT desc order by sum desc;
  +----------+----------------------------------------------------------------------------------------------------------------------------------------------+-------------------+
  | count(*) | SQL_TEXT                                                                                                                                     | sum               |
  +----------+----------------------------------------------------------------------------------------------------------------------------------------------+-------------------+
  |      694 | NULL                                                                                                                                         | 16834844969948000 |
  |      234 | select case when @@read_only + @@innodb_read_only = 0 then 1 else (select table_name from information_schema.tables) end as `1`              |       27505328000 |
  |        1 | SELECT count(*), SQL_TEXT, sum(TIMER_WAIT) as sum FROM performance_schema.events_statements_current group by SQL_TEXT desc order by sum desc |        9779103000 |
  |       28 | SET sql_mode='STRICT_TRANS_TABLES'                                                                                                           |        5755960000 |
  |        2 | SET autocommit=1                                                                                                                             |         721500000 |
  |        1 | SET @@sql_log_bin=on                                                                                                                         |         536095000 |
  |        9 | SELECT @@session.tx_read_only                                                                                                                |         375658000 |
  |        1 | PURGE BINARY LOGS BEFORE '2021-05-08 03:55:25'                                                                                               |         312794000 |
  |        1 | set local oscar_local_only_replica_host_status=0                                                                                             |         131821000 |
  |        1 | SELECT @@aurora_version                                                                                                                      |          93256000 |
  |        1 | SHOW MASTER STATUS                                                                                                                           |          27713000 |
  +----------+----------------------------------------------------------------------------------------------------------------------------------------------+-------------------+
  11 rows in set (0.02 sec)
  ```


- Processes grouped by state
  - many of them in the init state

  ```
  mysql> select count(*), sum(TIME),  STATE from INFORMATION_SCHEMA.PROCESSLIST where COMMAND <> "Sleep" group by STATE ;
  +----------+-----------+--------------------------------+
  | count(*) | sum(TIME) | STATE                          |
  +----------+-----------+--------------------------------+
  |        1 |         0 | checking query cache for query |
  |        1 |         0 | Creating sort index            |
  |        1 |         0 | Creating tmp table             |
  |        1 |         0 | delayed commit ok initiated    |
  |        1 |         0 | executing                      |
  |      111 |       464 | init                           |
  |        1 |      5985 | Sending binlog event to slave  |
  |        2 |         0 | Sending data                   |
  +----------+-----------+--------------------------------+
  8 rows in set (0.01 sec)
  ```


- getting ft cache size

  ```
  mysql> show global variables like 'innodb_ft_cache_size';
  +----------------------+---------+
  | Variable_name        | Value   |
  +----------------------+---------+
  | innodb_ft_cache_size | 8000000 |
  +----------------------+---------+
  1 row in set (0.00 sec)

  mysql> show global variables like 'innodb_ft_total_cache_size';
  +----------------------------+-----------+
  | Variable_name              | Value     |
  +----------------------------+-----------+
  | innodb_ft_total_cache_size | 640000000 |
  +----------------------------+-----------+
  1 row in set (0.01 sec)
  ```