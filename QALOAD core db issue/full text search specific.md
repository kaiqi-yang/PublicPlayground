https://dev.mysql.com/doc/refman/8.0/en/innodb-information-schema-fulltext_index-tables.html




### Full-text index
  - Reason being the wait event `fts_cache_rw_lock` takes most of the time. We haven't be able to fully validate that. Blocked by permission related issue. But will be the next step for investigation.
  ```
  mysql> SET GLOBAL innodb_ft_aux_table = 'paylater/order_detail';
  ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER privilege(s) for this operation
  ```


  deleted some old snapshots

` ``
Successfully deleted snapshot qaload-paylater-db-final-snapshot.
Successfully deleted snapshot qaload-paylater-db-instance-20200620020502965700000003-final-snapshot.
Successfully deleted snapshot qaload-paylater-db-v20-11-20200703.
Successfully deleted snapshot qaload-paylater-db-v20-3-20200226.
Successfully deleted snapshot qaload-paylater-db-v20-1-20200121-r4-final.
```