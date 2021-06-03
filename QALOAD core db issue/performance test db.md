```
mysql> SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST  order by TIME DESC LIMIT 10;
+------+-----------+---------------------+----------+-------------+------+-------------------------------+------+
| ID   | USER      | HOST                | DB       | COMMAND     | TIME | STATE                         | INFO |
+------+-----------+---------------------+----------+-------------+------+-------------------------------+------+
|  238 | debezium  | 10.203.75.224:55866 | NULL     | Binlog Dump | 9719 | Sending binlog event to slave | NULL |
|  227 | debezium  | 10.203.84.132:33682 | NULL     | Sleep       | 9718 | cleaned up                    | NULL |
|  244 | debezium  | 10.203.84.132:33714 | NULL     | Binlog Dump | 9718 | Sending binlog event to slave | NULL |
| 8758 | plsupport | 10.203.75.224:59520 | paylater | Sleep       |  920 | cleaned up                    | NULL |
| 8759 | plsupport | 10.203.75.224:59522 | paylater | Sleep       |  919 | cleaned up                    | NULL |
| 8760 | plsupport | 10.203.75.224:59524 | paylater | Sleep       |  918 | cleaned up                    | NULL |
| 8899 | plsupport | 10.203.75.224:59542 | paylater | Sleep       |  886 | cleaned up                    | NULL |
| 8900 | plsupport | 10.203.75.224:59544 | paylater | Sleep       |  883 | cleaned up                    | NULL |
| 8906 | plsupport | 10.203.75.224:59552 | paylater | Sleep       |  861 | cleaned up                    | NULL |
| 8908 | plsupport | 10.203.75.224:59554 | paylater | Sleep       |  855 | cleaned up                    | NULL |
+------+-----------+---------------------+----------+-------------+------+-------------------------------+------+
10 rows in set (0.01 sec)

```

```
mysql> SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST where time>10 and command<>"Sleep";
+-----+----------+---------------------+------+-------------+-------+------------------------------------------------------------------+------+
| ID  | USER     | HOST                | DB   | COMMAND     | TIME  | STATE                                                            | INFO |
+-----+----------+---------------------+------+-------------+-------+------------------------------------------------------------------+------+
| 238 | debezium | 10.203.75.224:55866 | NULL | Binlog Dump | 25565 | Master has sent all binlog to slave; waiting for binlog to be up | NULL |
| 244 | debezium | 10.203.84.132:33714 | NULL | Binlog Dump | 25564 | Master has sent all binlog to slave; waiting for binlog to be up | NULL |
+-----+----------+---------------------+------+-------------+-------+------------------------------------------------------------------+------+
2 rows in set (0.00 sec)
```


```
mysql> SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST  order by TIME DESC LIMIT 10;
+------+-----------+---------------------+----------+-------------+------+------------------------------------------------------------------+------+
| ID   | USER      | HOST                | DB       | COMMAND     | TIME | STATE                                                            | INFO |
+------+-----------+---------------------+----------+-------------+------+------------------------------------------------------------------+------+
|  238 | debezium  | 10.203.75.224:55866 | NULL     | Binlog Dump | 9762 | Master has sent all binlog to slave; waiting for binlog to be up | NULL |
|  227 | debezium  | 10.203.84.132:33682 | NULL     | Sleep       | 9761 | cleaned up                                                       | NULL |
|  244 | debezium  | 10.203.84.132:33714 | NULL     | Binlog Dump | 9761 | Master has sent all binlog to slave; waiting for binlog to be up | NULL |
| 8758 | plsupport | 10.203.75.224:59520 | paylater | Sleep       |  963 | cleaned up                                                       | NULL |
| 8759 | plsupport | 10.203.75.224:59522 | paylater | Sleep       |  962 | cleaned up                                                       | NULL |
| 8760 | plsupport | 10.203.75.224:59524 | paylater | Sleep       |  961 | cleaned up                                                       | NULL |
| 8899 | plsupport | 10.203.75.224:59542 | paylater | Sleep       |  929 | cleaned up                                                       | NULL |
| 8900 | plsupport | 10.203.75.224:59544 | paylater | Sleep       |  926 | cleaned up                                                       | NULL |
| 8906 | plsupport | 10.203.75.224:59552 | paylater | Sleep       |  904 | cleaned up                                                       | NULL |
| 8908 | plsupport | 10.203.75.224:59554 | paylater | Sleep       |  898 | cleaned up                                                       | NULL |
+------+-----------+---------------------+----------+-------------+------+------------------------------------------------------------------+------+
10 rows in set (0.05 sec)
```


```
mysql> SELECT *        FROM performance_schema.events_waits_summary_global_by_event_name order by COUNT_STAR DESC LIMIT 20;
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
| EVENT_NAME                                               | COUNT_STAR | SUM_TIMER_WAIT     | MIN_TIMER_WAIT | AVG_TIMER_WAIT | MAX_TIMER_WAIT  |
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
| wait/synch/rwlock/innodb/hash_table_locks                |  765886113 |     75720203361600 |          26400 |          98800 |     76294440000 |
| wait/synch/mutex/sql/THD::LOCK_thd_data                  |  265596197 |     24176890188000 |          29600 |          90800 |     21686096800 |
| wait/io/table/sql/handler                                |  140904308 | 142200139992974400 |          44000 |     1009196400 | 452626442920000 |
| wait/synch/mutex/innodb/trx_mutex                        |  129877773 |      5504552125600 |          26400 |          42000 |     12102104800 |
| wait/synch/mutex/sql/FILE_AS_TABLE::LOCK_shim_lists      |   79055312 |      4339416261600 |          29600 |          54800 |      7419651200 |
| wait/synch/mutex/sql/FILE_AS_TABLE::LOCK_offsets         |   67925010 |      3516664034400 |          29600 |          51600 |     25233372000 |
| wait/synch/mutex/innodb/os_mutex                         |   58314334 |     18522989901600 |          26400 |         317600 |     42679341600 |
| wait/synch/mutex/innodb/fil_system_mutex                 |   50636431 |      4218572004800 |          26400 |          83200 |      1133726400 |
| wait/synch/mutex/sql/LOCK_table_cache                    |   44849736 |      4645563462400 |          29600 |         103200 |     69173165600 |
| wait/synch/mutex/mysys/THR_LOCK::mutex                   |   44841121 |      9262382639200 |          29600 |         206400 |     97272142400 |
| wait/lock/table/sql/handler                              |   44811227 |     20591969963200 |          27200 |         459200 |     97275688000 |
| wait/synch/rwlock/sql/MDL_lock::rwlock                   |   36518701 |     12382528938400 |          28000 |         338800 |     60256788800 |
| wait/synch/mutex/innodb/buf_pool_mutex                   |   32907741 |      3063803620800 |          26400 |          92800 |     46419925600 |
| idle                                                     |   24137025 |    231783058000000 |              0 |        9000000 |    191951000000 |
| wait/synch/rwlock/sql/LOCK_grant                         |   19882093 |      1868188611200 |          33600 |          93600 |      1123013600 |
| wait/synch/rwlock/innodb/dict sys RW lock                |   17548722 |      2395672867200 |          26400 |         136400 |     18519972800 |
| wait/synch/rwlock/innodb/index_tree_rw_lock              |   17148151 |    123850115213600 |          26400 |        7222000 |    355373060000 |
| wait/io/aurora_respond_to_client                         |   16058953 |       970942257600 |           1200 |          60400 |        41112000 |
| wait/synch/mutex/sql/Query_cache::free_memory_list_mutex |   14722523 |     32733136506400 |          29600 |        2223200 |    246678007200 |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_log             |   13783654 |   2590353305963200 |          28000 |      187929200 |  37832183978400 |
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
20 rows in set (0.33 sec)

mysql> SELECT *        FROM performance_schema.events_waits_summary_global_by_event_name order by COUNT_STAR DESC LIMIT 20;
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
| EVENT_NAME                                               | COUNT_STAR | SUM_TIMER_WAIT     | MIN_TIMER_WAIT | AVG_TIMER_WAIT | MAX_TIMER_WAIT  |
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
| wait/synch/rwlock/innodb/hash_table_locks                |  765946776 |     75727105339200 |          26400 |          98800 |     76294440000 |
| wait/synch/mutex/sql/THD::LOCK_thd_data                  |  265627682 |     24180042064000 |          29600 |          90800 |     21686096800 |
| wait/io/table/sql/handler                                |  140915608 | 142200851476802400 |          44000 |     1009120400 | 452626442920000 |
| wait/synch/mutex/innodb/trx_mutex                        |  129880903 |      5504728536800 |          26400 |          42000 |     12102104800 |
| wait/synch/mutex/sql/FILE_AS_TABLE::LOCK_shim_lists      |   79073512 |      4340425900000 |          29600 |          54800 |      7419651200 |
| wait/synch/mutex/sql/FILE_AS_TABLE::LOCK_offsets         |   67942349 |      3517593083200 |          29600 |          51600 |     25233372000 |
| wait/synch/mutex/innodb/os_mutex                         |   58327733 |     18523501959200 |          26400 |         317200 |     42679341600 |
| wait/synch/mutex/innodb/fil_system_mutex                 |   50639952 |      4218812339200 |          26400 |          83200 |      1133726400 |
| wait/synch/mutex/sql/LOCK_table_cache                    |   44855661 |      4645907752000 |          29600 |         103200 |     69173165600 |
| wait/synch/mutex/mysys/THR_LOCK::mutex                   |   44847067 |      9263267166400 |          29600 |         206400 |     97272142400 |
| wait/lock/table/sql/handler                              |   44816775 |     20594328189600 |          27200 |         459200 |     97275688000 |
| wait/synch/rwlock/sql/MDL_lock::rwlock                   |   36523027 |     12383212036800 |          28000 |         338800 |     60256788800 |
| wait/synch/mutex/innodb/buf_pool_mutex                   |   32911647 |      3064002656000 |          26400 |          92800 |     46419925600 |
| idle                                                     |   24141429 |    231835354000000 |              0 |        9000000 |    191951000000 |
| wait/synch/rwlock/sql/LOCK_grant                         |   19884294 |      1868398103200 |          33600 |          93600 |      1123013600 |
| wait/synch/rwlock/innodb/dict sys RW lock                |   17551010 |      2395798160800 |          26400 |         136400 |     18519972800 |
| wait/synch/rwlock/innodb/index_tree_rw_lock              |   17150768 |    123850520201600 |          26400 |        7221200 |    355373060000 |
| wait/io/aurora_respond_to_client                         |   16061815 |       971013917200 |           1200 |          60400 |        41112000 |
| wait/synch/mutex/sql/Query_cache::free_memory_list_mutex |   14723528 |     32733233026400 |          29600 |        2222800 |    246678007200 |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_log             |   13786469 |   2590609417576800 |          28000 |      187909200 |  37832183978400 |
+----------------------------------------------------------+------------+--------------------+----------------+----------------+-----------------+
20 rows in set (0.34 sec)

```


```
mysql> SELECT *        FROM performance_schema.events_waits_summary_global_by_event_name order by SUM_TIMER_WAIT DESC LIMIT 20;
+----------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| EVENT_NAME                                               | COUNT_STAR | SUM_TIMER_WAIT     | MIN_TIMER_WAIT | AVG_TIMER_WAIT  | MAX_TIMER_WAIT   |
+----------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| wait/synch/rwlock/innodb/fts_cache_rw_lock               |      59332 | 508779337475188800 |          53600 |   8575125353200 |  450998380239200 |
| wait/io/table/sql/handler                                |  141078097 | 142209064493195200 |          44000 |      1008016400 |  452626442920000 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::COND_done             |     198206 |  23663295239785600 |              0 |    119387380800 |   37797986840000 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond           |     202805 |  16398570634603200 |              0 |     80858808000 | 3977415276077600 |
| wait/io/file/innodb/innodb_data_file                     |    7510475 |  11491395778979200 |              0 |      1530048800 |     837623315200 |
| wait/synch/cond/sql/FILE_AS_TABLE::cond_request          |         20 |   9962596795627200 |              0 | 498129839781200 | 2923090817257600 |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_log             |   13823528 |   2592922341224800 |          28000 |       187572800 |   37832183978400 |
| wait/io/file/sql/binlog                                  |    1675179 |   2155567456052000 |              0 |      1286768400 |     879252840000 |
| wait/synch/mutex/innodb/aurora_lock_thread_slot_futex    |        154 |    637333076910400 |       56016000 |   4138526473200 |   37794775280800 |
| idle                                                     |   22224362 |    214270302000000 |              0 |         9000000 |     191951000000 |
| wait/synch/rwlock/innodb/index_tree_rw_lock              |   17190427 |    123862369096800 |          26400 |         7205200 |     355373060000 |
| wait/io/socket/sql/client_connection                     |    7413470 |    107692320773600 |              0 |        14526400 |     496734560800 |
| wait/synch/rwlock/innodb/hash_table_locks                |  766844920 |     75828750730400 |          26400 |           98800 |      76294440000 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::prep_xids_cond        |          3 |     49195343865600 |              0 |  16398447955200 |   37718048772000 |
| wait/synch/mutex/sql/Query_cache::free_memory_list_mutex |   14736925 |     32734194348800 |          29600 |         2221200 |     246678007200 |
| wait/synch/mutex/sql/THD::LOCK_thd_data                  |  266093010 |     24224599316800 |          29600 |           90800 |      21686096800 |
| wait/lock/table/sql/handler                              |   44892559 |     20626572505600 |          27200 |          459200 |      97275688000 |
| wait/synch/mutex/innodb/os_mutex                         |   58863706 |     18540687516800 |          26400 |          314800 |      42679341600 |
| wait/synch/rwlock/sql/MDL_lock::rwlock                   |   36589171 |     12398866336000 |          28000 |          338800 |      60256788800 |
| wait/synch/mutex/sql/LOCK_plugin                         |   11304508 |      9830629792000 |          29600 |          869600 |     186388132000 |
+----------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
20 rows in set (0.33 sec)
```


```
mysql> SELECT *        FROM performance_schema.events_waits_summary_global_by_event_name order by AVG_TIMER_WAIT DESC LIMIT 20;
+-------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| EVENT_NAME                                            | COUNT_STAR | SUM_TIMER_WAIT     | MIN_TIMER_WAIT | AVG_TIMER_WAIT  | MAX_TIMER_WAIT   |
+-------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| wait/synch/cond/sql/FILE_AS_TABLE::cond_request       |         20 |   9962596795627200 |              0 | 498129839781200 | 2923090817257600 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::prep_xids_cond     |          3 |     49195343865600 |              0 |  16398447955200 |   37718048772000 |
| wait/synch/rwlock/innodb/fts_cache_rw_lock            |      59332 | 508779337475188800 |          53600 |   8575125353200 |  450998380239200 |
| wait/synch/mutex/innodb/aurora_lock_thread_slot_futex |        154 |    637333076910400 |       56016000 |   4138526473200 |   37794775280800 |
| wait/synch/cond/sql/COND_server_started               |          1 |       313511698400 |              0 |    313511698400 |     313511698400 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::COND_done          |     198206 |  23663295239785600 |              0 |    119387380800 |   37797986840000 |
| wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond        |     202821 |  16435228868529600 |              0 |     81033171200 | 3977415276077600 |
| wait/synch/cond/sql/COND_thread_count                 |          4 |       169801317600 |              0 |     42450329200 |     169230806400 |
| wait/io/file/innodb/innodb_data_file                  |    7510590 |  11491550574992800 |              0 |      1530046000 |     837623315200 |
| wait/io/file/sql/binlog_index                         |        259 |       374517384800 |              0 |      1446012800 |      11077864800 |
| wait/io/file/sql/binlog                               |    1675243 |   2155643882444800 |              0 |      1286764800 |     879252840000 |
| wait/io/table/sql/handler                             |  141081916 | 142209248182071200 |          44000 |      1007990400 |  452626442920000 |
| wait/io/file/sql/file_parser                          |        238 |       145220592800 |              0 |       610170400 |       8193793600 |
| wait/io/file/sql/dbopt                                |         15 |         5536544000 |              0 |       369102800 |       2527424800 |
| wait/io/file/csv/metadata                             |         72 |        19838367200 |              0 |       275532800 |       6921838400 |
| wait/io/file/sql/FRM                                  |       1821 |       497002992000 |              0 |       272928400 |      26253446400 |
| wait/synch/mutex/sql/LOG::LOCK_log                    |      13392 |      2911327080000 |          28800 |       217392800 |      32932692800 |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_log          |   13823696 |   2592922923855200 |          28000 |       187570800 |   37832183978400 |
| wait/synch/cond/sql/SERVER_THREAD::cond_checkpoint    |         23 |         2799972000 |              0 |       121737600 |        182345600 |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_index        |        142 |         5250864800 |          30400 |        36977600 |       2200428800 |
+-------------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
20 rows in set (0.32 sec)
```

```
mysql> use performance_schema;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------------------------------------+
| Tables_in_performance_schema                       |
+----------------------------------------------------+
| accounts                                           |
| cond_instances                                     |
| events_stages_current                              |
| events_stages_history                              |
| events_stages_history_long                         |
| events_stages_summary_by_account_by_event_name     |
| events_stages_summary_by_host_by_event_name        |
| events_stages_summary_by_thread_by_event_name      |
| events_stages_summary_by_user_by_event_name        |
| events_stages_summary_global_by_event_name         |
| events_statements_current                          |
| events_statements_history                          |
| events_statements_history_long                     |
| events_statements_summary_by_account_by_event_name |
| events_statements_summary_by_digest                |
| events_statements_summary_by_host_by_event_name    |
| events_statements_summary_by_thread_by_event_name  |
| events_statements_summary_by_user_by_event_name    |
| events_statements_summary_global_by_event_name     |
| events_waits_current                               |
| events_waits_history                               |
| events_waits_history_long                          |
| events_waits_summary_by_account_by_event_name      |
| events_waits_summary_by_host_by_event_name         |
| events_waits_summary_by_instance                   |
| events_waits_summary_by_thread_by_event_name       |
| events_waits_summary_by_user_by_event_name         |
| events_waits_summary_global_by_event_name          |
| file_instances                                     |
| file_summary_by_event_name                         |
| file_summary_by_instance                           |
| host_cache                                         |
| hosts                                              |
| mutex_instances                                    |
| objects_summary_global_by_type                     |
| performance_timers                                 |
| rds_events_threads_waits_current                   |
| rds_events_threads_waits_lock_current              |
| rds_processlist                                    |
| rwlock_instances                                   |
| session_account_connect_attrs                      |
| session_connect_attrs                              |
| setup_actors                                       |
| setup_consumers                                    |
| setup_instruments                                  |
| setup_objects                                      |
| setup_timers                                       |
| socket_instances                                   |
| socket_summary_by_event_name                       |
| socket_summary_by_instance                         |
| table_io_waits_summary_by_index_usage              |
| table_io_waits_summary_by_table                    |
| table_lock_waits_summary_by_table                  |
| threads                                            |
| users                                              |
+----------------------------------------------------+
55 rows in set (0.00 sec)
```
select * from performance_schema.events_stages_summary_global_by_event_name order by SUM_TIMER_WAIT desc limit 10;
select * from performance_schema.events_waits_summary_by_host_by_event_name order by SUM_TIMER_WAIT desc limit 10;
select count(*) from performance_schema.events_statements_summary_global_by_event_name;
select * from performance_schema.events_waits_summary_global_by_event_name order by SUM_TIMER_WAIT desc limit 10;


select * from performance_schema.events_statements_current limit 10;


Select COUNT(*) as cnt, SUM(TIMER_WAIT) as sum, EVENT_NAME from events_waits_current group by EVENT_NAME order by sum desc;

```
mysql> Select COUNT(*) as cnt, SUM(TIMER_WAIT) as sum, EVENT_NAME from events_waits_current group by EVENT_NAME order by sum desc;
+-----+------------------+-------------------------------------------------+
| cnt | sum              | EVENT_NAME                                      |
+-----+------------------+-------------------------------------------------+
|   2 | 5846443607517600 | wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond  |
|   1 | 3091498876969600 | wait/synch/cond/sql/FILE_AS_TABLE::cond_request |
|   1 |     313511698400 | wait/synch/cond/sql/COND_server_started         |
| 326 |         11333600 | wait/synch/mutex/sql/THD::LOCK_thd_data         |
|  39 |          5161600 | wait/synch/mutex/innodb/os_mutex                |
|   2 |          1528000 | wait/synch/mutex/mysys/THR_LOCK_threads         |
|   1 |           520800 | wait/synch/mutex/sql/SERVER_THREAD::LOCK_sync   |
|   1 |           360000 | wait/synch/mutex/innodb/lock_wait_mutex         |
|   1 |           265600 | wait/synch/mutex/sql/LOCK_thread_count          |
|   1 |           236800 | wait/synch/mutex/innodb/ibuf_mutex              |
|   2 |           104000 | wait/synch/mutex/innodb/trx_sys_mutex           |
|   1 |            58400 | wait/synch/rwlock/innodb/trx_purge_latch        |
|   1 |            54400 | wait/synch/mutex/sql/LOCK_plugin                |
|   1 |            44000 | wait/synch/rwlock/innodb/dict sys RW lock       |
|   1 |            31200 | wait/synch/mutex/innodb/fil_system_mutex        |
+-----+------------------+-------------------------------------------------+
```



```
mysql> use INFORMATION_SCHEMA;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> 
mysql> show tables;
+-----------------------------------------+
| Tables_in_information_schema            |
+-----------------------------------------+
| CHARACTER_SETS                          |
| COLLATIONS                              |
| COLLATION_CHARACTER_SET_APPLICABILITY   |
| COLUMNS                                 |
| COLUMN_PRIVILEGES                       |
| ENGINES                                 |
| EVENTS                                  |
| FILES                                   |
| GLOBAL_STATUS                           |
| GLOBAL_VARIABLES                        |
| KEY_COLUMN_USAGE                        |
| OPTIMIZER_TRACE                         |
| PARAMETERS                              |
| PARTITIONS                              |
| PLUGINS                                 |
| PROCESSLIST                             |
| RDS_PROCESSLIST                         |
| AURORA_OBJECTPOOL_INFO                  |
| RDS_CONTROL_PERFORMANCE_INSIGHTS_STATUS |
| PROFILING                               |
| REFERENTIAL_CONSTRAINTS                 |
| ROUTINES                                |
| SCHEMATA                                |
| SCHEMA_PRIVILEGES                       |
| SESSION_STATUS                          |
| SESSION_VARIABLES                       |
| STATISTICS                              |
| TABLES                                  |
| TABLESPACES                             |
| TABLE_CONSTRAINTS                       |
| TABLE_PRIVILEGES                        |
| TRIGGERS                                |
| USER_PRIVILEGES                         |
| VIEWS                                   |
| REPLICA_HOST_STATUS                     |
| RDS_METRICS_META                        |
| RDS_METRICS_GAUGE                       |
| RDS_METRICS_COUNTER                     |
| INNODB_LOCKS                            |
| INNODB_TRX                              |
| INNODB_SYS_DATAFILES                    |
| INNODB_LOCK_WAITS                       |
| INNODB_SYS_TABLESTATS                   |
| INNODB_CMP                              |
| INNODB_SYS_INDEXES_HISTORY              |
| INNODB_CMP_RESET                        |
| INNODB_CMP_PER_INDEX                    |
| INNODB_CMPMEM_RESET                     |
| INNODB_FT_DELETED                       |
| INNODB_BUFFER_PAGE_LRU                  |
| INNODB_FT_INSERTED                      |
| INNODB_CMPMEM                           |
| INNODB_SYS_INDEXES                      |
| INNODB_SYS_TABLES                       |
| INNODB_SYS_FIELDS                       |
| INNODB_CMP_PER_INDEX_RESET              |
| INNODB_BUFFER_PAGE                      |
| INNODB_FT_BEING_DELETED                 |
| INNODB_FT_INDEX_TABLE                   |
| INNODB_FT_INDEX_CACHE                   |
| INNODB_SYS_TABLESPACES                  |
| INNODB_METRICS                          |
| INNODB_SYS_FOREIGN_COLS                 |
| INNODB_SYS_FOREIGN                      |
| INNODB_BUFFER_POOL_STATS                |
| INNODB_SYS_COLUMNS                      |
| INNODB_SYS_FIELDS_HISTORY               |
| INNODB_SYS_SCHEMA_HISTORY               |
| INNODB_FT_DEFAULT_STOPWORD              |
| INNODB_SYS_COLUMNS_HISTORY              |
| INNODB_SYS_TABLES_HISTORY               |
| INNODB_FT_CONFIG                        |
+-----------------------------------------+
72 rows in set (0.00 sec)
```


```sql
select count(*) from INFORMATION_SCHEMA.INNODB_FT_INDEX_CACHE;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_CONFIG;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_DEFAULT_STOPWORD;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_INDEX_TABLE;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_BEING_DELETED;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_INSERTED;
select count(*) from INFORMATION_SCHEMA.INNODB_FT_DELETED;

```


```
mysql> select * from performance_schema.events_waits_summary_by_host_by_event_name order by SUM_TIMER_WAIT desc limit 12;
+---------------+-------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| HOST          | EVENT_NAME                                      | COUNT_STAR | SUM_TIMER_WAIT     | MIN_TIMER_WAIT | AVG_TIMER_WAIT  | MAX_TIMER_WAIT   |
+---------------+-------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
| 10.203.74.176 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      18688 | 109723131225317600 |          55200 |   5871314812800 |  450998380239200 |
| 10.203.75.129 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      18792 | 108827255283797600 |          54400 |   5791148110000 |  443393906475200 |
| 10.203.76.70  | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      18523 | 108634294185728000 |          55200 |   5864832596400 |  446694853987200 |
| 10.203.74.221 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      10366 |  27229337154180800 |          53600 |   2626793088000 |  373056795928000 |
| 10.203.76.173 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      10406 |  25972405154167200 |          56000 |   2495906703200 |  404310954160800 |
| 10.203.75.129 | wait/io/table/sql/handler                       |    2086424 |  25066681863584800 |          45600 |     12014184000 |  452626442920000 |
| 10.203.76.70  | wait/io/table/sql/handler                       |    2059350 |  24921746839582400 |          45600 |     12101753600 |  446815514914400 |
| 10.203.75.242 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      10473 |  24349092044081600 |          55200 |   2324939562800 |  383344114054400 |
| 10.203.74.176 | wait/io/table/sql/handler                       |    2065846 |  24107813168689600 |          45600 |     11669704800 |  451115608254400 |
| NULL          | wait/synch/cond/sql/FILE_AS_TABLE::cond_request |         42 |  23462620663421600 |        7992000 | 558633825319200 | 3150229597086400 |
| 10.203.74.48  | wait/synch/rwlock/innodb/fts_cache_rw_lock      |      10337 |  22846047723526400 |          55200 |   2210123606800 |  396969047487200 |
| 10.203.75.222 | wait/synch/rwlock/innodb/fts_cache_rw_lock      |       7731 |  21182341520094400 |          53600 |   2739922586800 |  440272741477600 |
+---------------+-------------------------------------------------+------------+--------------------+----------------+-----------------+------------------+
12 rows in set (0.99 sec)
```




```

mysql> SELECT count(*), SOURCE        FROM performance_schema.events_waits_current group by SOURCE;
+----------+-----------------------+
| count(*) | SOURCE                |
+----------+-----------------------+
|        1 | binlog.cc:6439        |
|        1 | dict0dict.cc:221      |
|        1 | fil0fil.cc:6218       |
|        1 | file_as_table.cc:3659 |
|        1 | grover_repl.cc:2556   |
|        1 | ibuf0ibuf.cc:2846     |
|        1 | lock0newlock.cc:6180  |
|        1 | lock0newwait.cc:792   |
|        1 | mysqld.cc:1698        |
|        1 | mysqld.cc:4577        |
|        2 | my_thr_init.c:359     |
|       39 | os0sync.cc:899        |
|     1021 | sql_class.cc:5689     |
|        1 | sql_class.h:2234      |
|        1 | sql_plugin.cc:796     |
|        1 | srv0srv.cc:2852       |
|        1 | trx0trx.cc:741        |
+----------+-----------------------+
17 rows in set (0.00 sec)

mysql> SELECT count(*), EVENT_NAME     FROM performance_schema.events_waits_current group by EVENT_NAME;
+----------+-------------------------------------------------+
| count(*) | EVENT_NAME                                      |
+----------+-------------------------------------------------+
|        1 | wait/synch/cond/sql/COND_server_started         |
|        1 | wait/synch/cond/sql/FILE_AS_TABLE::cond_request |
|        1 | wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond  |
|        1 | wait/synch/mutex/innodb/ibuf_mutex              |
|        1 | wait/synch/mutex/innodb/lock_wait_mutex         |
|        1 | wait/synch/mutex/innodb/log_sys_mutex           |
|       39 | wait/synch/mutex/innodb/os_mutex                |
|        2 | wait/synch/mutex/innodb/trx_sys_mutex           |
|        2 | wait/synch/mutex/mysys/THR_LOCK_threads         |
|        1 | wait/synch/mutex/sql/LOCK_plugin                |
|        1 | wait/synch/mutex/sql/LOCK_thread_count          |
|        1 | wait/synch/mutex/sql/SERVER_THREAD::LOCK_sync   |
|      997 | wait/synch/mutex/sql/THD::LOCK_thd_data         |
|        1 | wait/synch/rwlock/innodb/dict sys RW lock       |
|        1 | wait/synch/rwlock/innodb/trx_purge_latch        |
+----------+-------------------------------------------------+
15 rows in set (0.01 sec)
```



mysql> mysql> Select COUNT(*) as cnt, SUM(TIMER_WAIT) as sum, EVENT_NAME from performance_schema.events_waits_current group by EVENT_NAME order by sum desc;
+------+------------------+-------------------------------------------------+
| cnt  | sum              | EVENT_NAME                                      |
+------+------------------+-------------------------------------------------+
|    1 | 2882580366112000 | wait/synch/cond/sql/FILE_AS_TABLE::cond_request |
|    1 |     324701005600 | wait/synch/cond/sql/COND_server_started         |
|    1 |      75961120800 | wait/synch/cond/sql/MYSQL_BIN_LOG::update_cond  |
| 1040 |         38789600 | wait/synch/mutex/sql/THD::LOCK_thd_data         |
|   39 |          2165600 | wait/synch/mutex/innodb/os_mutex                |
|    2 |          1252800 | wait/synch/mutex/mysys/THR_LOCK_threads         |
|    1 |           363200 | wait/synch/mutex/sql/SERVER_THREAD::LOCK_sync   |
|    1 |           336800 | wait/synch/mutex/sql/LOCK_thread_count          |
|    1 |           212000 | wait/synch/mutex/innodb/lock_wait_mutex         |
|    1 |           141600 | wait/synch/mutex/innodb/ibuf_mutex              |
|    2 |           124000 | wait/synch/mutex/innodb/trx_sys_mutex           |
|    1 |           114400 | wait/synch/rwlock/innodb/dict sys RW lock       |
|    1 |           113600 | wait/synch/mutex/innodb/log_sys_mutex           |
|    1 |            81600 | wait/synch/rwlock/innodb/trx_purge_latch        |
|    1 |            53600 | wait/synch/mutex/sql/LOCK_plugin                |
+------+------------------+-------------------------------------------------+
15 rows in set (0.01 sec)



