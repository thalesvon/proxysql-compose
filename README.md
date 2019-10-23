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


## Create CloudFormation Stack

```
aws cloudformation create-stack --stack-name demo --template-body file://cloudformation/ecs-cluster.yml \
--capabilities CAPABILITY_IAM --parameters ParameterKey=ProxySQLContainerImage, \  ParameterValue=212568053769.dkr.ecr.us-east-1.amazonaws.com/boomcredit/proxy-sql:latest
```