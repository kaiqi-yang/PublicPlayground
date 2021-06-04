SHOW engine innodb status;
SHOW global status;
SHOW FULL PROCESSLIST \G;
SHOW ENGINE INNODB STATUS \G;


SELECT r.trx_id waiting_trx_id,
     r.trx_mysql_thread_id waiting_thread,
     r.trx_query waiting_query,
     b.trx_id blocking_trx_id,
     b.trx_mysql_thread_id blocking_thread,
     b.trx_query blocking_query
     FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;

select * from information_schema.innodb_trx;

select * from information_schema.innodb_locks;

select * from information_schema.innodb_lock_waits;