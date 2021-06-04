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

  ### AWS support ticket
-------
Hello,

I hope this email finds you well! Thank you for reaching out to AWS Premium Support and for your immense patience as your case was being looked into.
My name is Sangeeth and I will be working with you on on behalf of the RDS technical support team today.

#### CASE DESCRIPTION
-------

From the case correspondence, I understand that you experience performance issues and occurrence of wait events on the Aurora Cluster “qaload-paylater-db”  when performing a load test on the Cluster. 
Please correct me if I have misunderstood your query.

####  OBSERVATION AND ANALYSIS
-------

To start with, I looked into the Aurora Instance  `qaload-paylater-db-instance-20210319065940380500000003` and its underlying host of instances to rule out any hardware issues and  I could observe no perceivable issue with underlying host that could have caused the performance issue . I have  examined the storage volumes and can confirm that they are healthy as well.

Additionally, I checked for any network issues or packet loss in the ‘ap-southeast-2’ region where your RDS is located and can confirm that there was no such issue.

Next I looked into the Cloud watch graphs of the instance `qaload-paylater-db-instance-20210319065940380500000003`  for the past weeks to check if there were any resource contention issues.
Below are my observations.

The CPU Utilzation was below 50%
```
https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#metricsV2:graph=~(stat~'Average~period~60~start~'-P3D~end~'P0D~region~'ap-southeast-2~view~'timeSeries~stacked~false~metrics~(~(~'AWS*2fRDS~'CPUUtilization~'DBInstanceIdentifier~'qaload-paylater-db-instance-20210319065940380500000003) ));query=~'*7bAWS*2fRDS*2cDBInstanceIdentifier*7d*20rds*20qaload-paylater-db-instance-20210319065940380500000003
```

The Select, DML Insert and Update latencies were all well with the limits of single digit millisecond. 

```
https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#metricsV2:graph=~(stat~'Average~period~60~start~'-P3D~end~'P0D~region~'ap-southeast-2~view~'timeSeries~stacked~false~metrics~(~(~'AWS*2fRDS~'SelectLatency~'DBInstanceIdentifier~'qaload-paylater-db-instance-20210319065940380500000003)~(~'.~'InsertLatency~'.~'.)~(~'.~'DMLLatency~'.~'.)~(~'.~'UpdateLatency~'.~'.) ));query=~'*7bAWS*2fRDS*2cDBInstanceIdentifier*7d*20rds*20qaload-paylater-db-instance-20210319065940380500000003
```

I could observe slight elevations in Row lock time metric and Blocked Transactions.
```

https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#metricsV2:graph=~(view~'timeSeries~stacked~false~start~'-P3D~end~'P0D~region~'ap-southeast-2~stat~'Average~period~60~metrics~(~(~'AWS*2fRDS~'RowLockTime~'DBInstanceIdentifier~'qaload-paylater-db-instance-20210319065940380500000003) ));query=~'*7bAWS*2fRDS*2cDBInstanceIdentifier*7d*20qaload-paylater-db-instance-20210319065940380500000003

https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#metricsV2:graph=~(view~'timeSeries~stacked~false~start~'-P3D~end~'P0D~region~'ap-southeast-2~stat~'Average~period~60~metrics~(~(~'AWS*2fRDS~'BlockedTransactions~'DBInstanceIdentifier~'qaload-paylater-db-instance-20210319065940380500000003) ));query=~'*7bAWS*2fRDS*2cDBInstanceIdentifier*7d*20qaload-paylater-db-instance-20210319065940380500000003
```

The metric row locktime indicates the total time spent acquiring row locks for InnoDB tables.

In Innodb tables, When a transaction updates a row in a table, or locks it with SELECT FOR UPDATE, InnoDB establishes a list or queue of locks on that row. Similarly, InnoDB maintains a list of locks on a table for table-level locks. If a second transaction wants to update a row or lock a table already locked by a prior transaction in an incompatible mode, InnoDB adds a lock request for the row to the corresponding queue. For a lock to be acquired by a transaction, all incompatible lock requests previously entered into the lock queue for that row or table must be removed (which occurs when the transactions holding or requesting those locks either commit or roll back).

>Blocking normally happens when multiple write transactions occur concurrently on the same table or row. As write transaction needs to acquire exclusive lock, which, the first write transaction, if it is not finished (committed or rolled back yet), would prevents other later transactions to write to the same data, so to ensure the data consistency.

I could also observe elevations in  `RollbackSegmentHistoryListLength` metrics.

```
https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#metricsV2:graph=~(stat~'Average~period~60~start~'-P3D~end~'P0D~region~'ap-southeast-2~view~'timeSeries~stacked~false~metrics~(~(~'AWS*2fRDS~'RollbackSegmentHistoryListLength~'DBInstanceIdentifier~'qaload-paylater-db-instance-20210319065940380500000003) ));query=~'*7bAWS*2fRDS*2cDBInstanceIdentifier*7d*20rds*20qaload-paylater-db-instance-20210319065940380500000003
```

A high history list length can cause a lot of problems in terms of performance, because transactions might have to, for each row they read from a table, read a chain of undo records, and these are likely in memory, additional resources will be required to access the several versions of each row, instead of accessing only the current one. It can also slow down statements because the older a transaction is, and the more other transactions have modified data that the old transaction wants to access, the larger the undo chains will be, slowing down even more the older transaction.

#### Analysis 
-------

Now, as the were no infrastructure issues or resource crunch on the Aurora Instance, I suspect that the performance issue that you were experiencing is due to presence or locks on the database. 

Additionally, from the images that you have provided I see that the innoDB_buffer_pool_hits are higher with consecutive load  I believe this difference in performance (in terms of query execution time) could be due to the fact that during first run, the workload involved disk bound operations- hence queries were fetching data from the storage into the memory - this caused the wait events that you noticed in the PI dashboard as well. Now during next run, this data was readily available in the buffer pool and hence the same set of queries accessing same data didn't have to go to the disk- hence saving on execution time. 

Having said the above, it is of course a possibility among several others. In order to confirm this, it would help if you have any saved outputs of innodb engine status, global status that can help in identifying details of transactions running, buffer pool usage, disk access etc. If these outputs are not available, I would suggest you to retry the workload again and this time you can run `show engine innodb status` and `show global status` continuously at an interval of 5-10 seconds (with help of a custom script) - as this will provide the essential data needed to compare what is happening at the engine level, how operations are being performed, what locks exist, what transactions are blocking etc.

References:
- https://dev.mysql.com/doc/refman/5.6/en/innodb-standard-monitor.html 
- https://dev.mysql.com/doc/refman/5.6/en/show-status.html 


Furthermore, as you have insightfully enabled Performance insights I looked into the metrics during the frequent times of wait event  and could observe the following wait events generated. 

`wait/synch/sxlock/innodb/fts_cache_rw_lock event`

If you will notice the entire wait event, it can be broken down into a tree like structure. "wait/synch" is an instrumented synchronization object.  "wait/synch/rwlock" is basically a read/write lock object used to lock a specific variable for access while preventing its use by other threads. This info can be found in the below link:
- https://dev.mysql.com/doc/refman/5.6/en/performance-schema-instrument-naming.html 

Now, "wait/synch/sxlock/innodb/" - is nothing but locks at innodb engine level. I could not find much info on `fts_cache_rw_lock event` but as the name suggests it is either a read or write lock, a synchronised event for full text index.


further dive deep on the PI tools resulted in identifying below queries which caused the DB load to increase:
The following is the SQL SupportID of the queries
Metric value from 2021-05-14 (03:45:00) - 2021-05-14 (04:00:00) (UTC

```
SQL Digest Hkid
2263378EA8BAF63089740A1BC0BF5DE7EC5D5162
CDA6FD1A5E349D9424C629D29ABF55A7BFAC9C30
```

Due to security reasons we Support Engineers are not aware which exact query is running, however by using the above mentioned SQL Support ID you can identify the query which is causing the  heavy DB load and hence tuning the query will help you balance the DB load.

To decrypt the SQL query by the SQL Support ID you will need to enable Support ID in your Performance insights Dashboard:
Please follow the below steps to do so:
1. Open the Amazon RDS console at https://console.aws.amazon.com/rds/ . 
2. In the navigation pane, choose Performance Insights. 
3. Choose a DB instance. The Performance Insights dashboard is displayed for that DB instance. 
4. Click on the Settings  Button next to the Search Bar
5. You will come across a PopUp (Preferences)
6. Select the Support ID Toggle.

After this, you will be able to identify the percentage of the database load associated with query and queries that are causing the locks on the Database.

As Support Engineer due to security and privacy reasons, we do not have visibility into your instance or the queries running on it, so I cannot confirm why queries were running on the instance are running that is causing the increase in commit latency
However I can suggest you some queries that you can run  on your instance during times of commit latency in your database to gather useful troubleshooting information/ identify any issues on the database.

Moving ahead, You may find below details helpful in further troubleshooting which needs to be done at your end. 

1.  The SHOW PROCESSLIST command will display the currently open connections and its queries, user and host, and how many seconds since the last change int he status of the connection: 
  - http://dev.mysql.com/doc/refman/5.6/en/show-processlist.html 

    ` mysql> SHOW FULL PROCESSLIST \G`

2. The SHOW ENGINE INNODB STATUS \G will provide a lot of useful information, specially the currently running transactions, last detected deadlock, Foreign Key errors, IO statistics and semaphores. 
  - http://dev.mysql.com/doc/refman/5.6/en/innodb-monitors.html 

    `mysql> SHOW ENGINE INNODB STATUS \G`

3. One of the common reasons for the performance impact  in MySQL DB Engine is occurrence of deadlocks or locking contention issues
The below query can display the locks if there is any. It uses INFORMATION_SCHEMA tables [INNODB_TRX, INNODB_LOCKS, and INNODB_LOCK_WAITS] which gives you information on current transactions, current locks and current lock waits.

```
 mysql> SELECT r.trx_id waiting_trx_id,
     r.trx_mysql_thread_id waiting_thread,
     r.trx_query waiting_query,
     b.trx_id blocking_trx_id,
     b.trx_mysql_thread_id blocking_thread,
     b.trx_query blocking_query
     FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

You may need to rerun the above command multiple times, to fetch the exact locks.

4. `mysql> select * from information_schema.innodb_trx;`

    The INNODB_TRX table contains information about every transaction (excluding read-only transactions) currently executing inside InnoDB, including whether the transaction is waiting for a lock when the transaction started, and the SQL statement the transaction is executing, if any.  For more information, please refer to link below.
 https://dev.mysql.com/doc/refman/5.6/en/innodb-trx-table.html 

 5. `mysql> select * from information_schema.innodb_locks;`
     
    The INNODB_LOCKS table contains information about each lock that an InnoDB transaction has requested but not yet acquired, and each lock that a transaction holds that is blocking another transaction. For more information, please refer to link below.
https://dev.mysql.com/doc/refman/5.6/en/innodb-locks-table.html 

 6. `mysql> select * from information_schema.innodb_lock_waits;`
    
    The INNODB_LOCK_WAITS table contains one or more rows for each blocked InnoDB transaction, indicating the lock it has requested and any locks that are blocking that request. For more information, please refer to link below.
 https://dev.mysql.com/doc/refman/5.6/en/innodb-lock-waits-table.html 

You may need to rerun the above command multiple times, to fetch the exact locks.

7. One useful parameter for checking deadlocks and resource locking is 'innodb_print_all_deadlocks'. When this parameter is enabled, information about all deadlocks in InnoDB user transactions is recorded in the mysqld error log. 
 https://dev.mysql.com/doc/refman/5.6/en/innodb-parameters.html#sysvar_innodb_print_all_deadlocks 

8. Additionally, you can also check slow query log to identify the slow running queries, if they run slower than expected, they could be the victim of blocking issue. Identifying these queries would help you reviewing the application or workload.
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.MySQL.html#USER_LogAccess.MySQL.Generallog 


9. To know how long a query normally runs for, after having the query, you may use profiling [5] to measure it when it is not blocked, a quick example:

```
SET profiling = 1;
select/insert/update/delete ....       <------ run your query here
SHOW PROFILES;    <------ find the id for above query
SHOW PROFILE CPU FOR QUERY #;     <---- this shows the CPU cost for the query
```

To disable it: SET profiling = 0;

10. Kindly refer to links below for the recommendations for troubleshooting blocking. And refer them for more useful performance tuning queries.
https://aws.amazon.com/premiumsupport/knowledge-center/blocked-mysql-query/ 


11. To kill a query that you feel is affecting your instance, you may use the following RDS procedure :
     mysql> CALL mysql.rds_kill(processID);
 mysql.rds_kill - http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/mysql_rds_kill.html 
   

I hope the above information is helpful and answers your queries. If you have any questions regarding the same, or if you feel my response requires further elaboration please feel free to reach out to me I will be happy to help

Stay Safe and have a nice day 😊

Thank you.

We value your feedback. Please share your experience by rating this correspondence using the AWS Support Center link at the end of this correspondence. Each correspondence can also be rated by selecting the stars in top right corner of each correspondence within the AWS Support Center.

Best regards,
Sangeeth D.
Amazon Web Services

---------------

To share your experience or contact us again about this case, please return to the AWS Support Center using the following URL: https://console.aws.amazon.com/support/home#/case/?displayId=8337445831&language=en 

Note, this e-mail was sent from an address that cannot accept incoming e-mails.
To respond to this case, please follow the link above to respond from your AWS Support Center.

---------------

AWS Support:
https://aws.amazon.com/premiumsupport/knowledge-center/ 

AWS Documentation:
https://docs.aws.amazon.com/ 

AWS Cost Management:
https://aws.amazon.com/aws-cost-management/ 

AWS Training:
http://aws.amazon.com/training/ 

AWS Managed Services:
https://aws.amazon.com/managed-services/ 