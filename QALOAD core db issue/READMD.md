# QALOAD core db issue

## Symptoms 
- Overall
  - QALOAD test failed randomly because of high error rate and high latency
  - QALOAD test behave very differently with same config and same traffic, reflected in the latency of requests as well as db performance
- Proofs
  - performance of API varies between two runs of same traffic
    - ![](performance%20of%20API%20varies%20between%20two%20runs%20of%20same%20traffic.png)
    - APIs with more than 15s latency, causing the build to fail.

## Indicators

### `fts_cache_rw_lock` 

- Wait event `wait/synch/rwlock/innodb/fts_cache_rw_lock` contributes to most of the difference between two runs
  - ![](wait%20event%20contributes%20to%20most%20of%20the%20vcpu%20difference%20between%20two%20runs.png)
  - Based on the mysql documentation on [Wait Instrument Elements Naming Conventions](https://dev.mysql.com/doc/refman/5.6/en/performance-schema-instrument-naming.html#performance-schema-wait-instrument-elements), we know that it's related to wait events on read write locks of full-text-search cache.
    - [InnoDB Full-Text Index Cache](https://dev.mysql.com/doc/refman/5.6/en/innodb-fulltext-index.html#innodb-fulltext-index-cache)
      > When a document is inserted, it is tokenized, and the individual words and associated data are inserted into the full-text index. This process, even for small documents, can result in numerous small insertions into the auxiliary index tables, making concurrent access to these tables a point of contention. To avoid this problem, InnoDB uses a full-text index cache to temporarily cache index table insertions for recently inserted rows. This in-memory cache structure holds insertions until the cache is full and then batch flushes them to disk (to the auxiliary index tables). You can query the INFORMATION_SCHEMA.INNODB_FT_INDEX_CACHE table to view tokenized data for recently inserted rows.

      > The innodb_ft_cache_size variable is used to configure the full-text index cache size (on a per-table basis), which affects how often the full-text index cache is flushed. You can also define a global full-text index cache size limit for all tables in a given instance using the innodb_ft_total_cache_size variable.
    - [The INFORMATION_SCHEMA INNODB_FT_INDEX_CACHE Table](https://dev.mysql.com/doc/refman/5.6/en/information-schema-innodb-ft-index-cache-table.html)
      > The INNODB_FT_INDEX_CACHE table provides token information about newly inserted rows in a FULLTEXT index. To avoid expensive index reorganization during DML operations, the information about newly indexed words is stored separately, and combined with the main search index only when OPTIMIZE TABLE is run, when the server is shut down, or when the cache size exceeds a limit defined by the innodb_ft_cache_size or innodb_ft_total_cache_size system variable.


### `buffer_pool_hits`
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


### `auroraStorageBytesTx`

- good range: below 100m
- bad range: more than 200m
- ![](auroraStorageBytesTx%20trend.png)
  - The number of bytes uploaded for aurora storage per second

- `auroraStorageBytesTx`
  - The number of bytes uploaded for aurora storage per second. (Writes)
- `auroraStorageBytesRx`
  - The number of bytes received for aurora storage per second. (Reads)




## Theories

### Store procedures or other sql executing
  - Hightly not possible
  - Used the following sql while the load is on, the result states the processes are clean
  ```
  mysql> select user, db, command, time, state from INFORMATION_SCHEMA.PROCESSLIST where COMMAND <> "Sleep";
  +----------+----------+-------------+-------+------------------------------------------------------------------+
  | user     | db       | command     | time  | state                                                            |
  +----------+----------+-------------+-------+------------------------------------------------------------------+
  | dbadmin  | paylater | Query       |     0 | executing                                                        |
  | debezium | NULL     | Binlog Dump | 21922 | Master has sent all binlog to slave; waiting for binlog to be up |
  +----------+----------+-------------+-------+------------------------------------------------------------------+
  2 rows in set (0.00 sec)
  ```
### Reached Network capacity
  - The reason being when you zoom in while the database is handling load, the wait time and `auroraStorageBytesTx` is showing a saturation. It seems like it's capped.
    - ![](The%20database%20load%20shows%20a%20saturation.png)
  - Current instance (`db.r5.4xlarge`) is capped at `4,750` `Dedicated EBS Bandwidth (Mbps)`, and `Up to 10` `Networking Performance (Gbps)` based on this [page](https://aws.amazon.com/rds/instance-types/).
  - We have tried to use `db.r5.16xlarge` which is capped at `13,600` and	`20` for those two figures respectively, and problem is the same with `auroraStorageBytesTx` stays at the same level as the `db.r5.4xlarge` instance. The problem in this case lasted longer than usual, it when on for more than 5 hours.
    - ![](db.r5.16xlarge%20presents%20the%20same%20problem.png)
### Writing in memory data received during load to the storage
  - When we run shorter load test, the problem lasts less time. But this is still to be confirmed. 

### Full-text index
  - Reason being the wait event `fts_cache_rw_lock` takes most of the time. We haven't be able to fully validate that. Blocked by permission related issue. But will be the next step for investigation.
  ```
  mysql> SET GLOBAL innodb_ft_aux_table = 'paylater/order_detail';
  ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER privilege(s) for this operation

  ```


