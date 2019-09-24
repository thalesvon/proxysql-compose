# Start

```
$ ./init-compose.bash local | rds
```


## Admin Queries

```
Admin>select hostgroup, schemaname, username, digest, digest_text, count_star from stats_mysql_query_digest;


Admin>SELECT * FROM monitor.mysql_server_ping_log ORDER BY time_start_us DESC LIMIT 10;

Admin>SELECT * FROM stats.stats_mysql_connection_pool;
```