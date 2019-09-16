#!/bin/bash
set -e

echo 'Startin ProxySQL'
service proxysql start

cat <<EOF > /proxy-sql.sql
delete from mysql_servers where hostgroup_id in (10,20);
delete from mysql_replication_hostgroups where writer_hostgroup=10;
INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight,max_connections) VALUES ('$WRITER_ENDPOINT',10,3306,1000,2000);
INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight,max_connections) VALUES ('$READER_ENDPOINT',20,3306,1000,2000);
INSERT INTO mysql_replication_hostgroups (writer_hostgroup,reader_hostgroup,comment,check_type) VALUES (10,20,'aws-aurora','innodb_read_only');
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;

delete from mysql_query_rules where rule_id in (50,51);
INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply) VALUES (50,1,'^SELECT.*FOR UPDATE$',10,1), (51,1,'^SELECT',20,1);
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;

delete from mysql_users where username='$DB_USER';
insert into mysql_users (username,password,active,default_hostgroup,default_schema,transaction_persistent) values ('$DB_USER','$DB_PASSWORD',1,10,'$DB_SCHEMA_NAME',1);
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;

UPDATE global_variables SET variable_value='root' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='mysql' WHERE variable_name='mysql-monitor_password';
UPDATE global_variables SET variable_value='5.7.26' WHERE variable_name='mysql-server_version';
UPDATE global_variables SET variable_value='2000' WHERE variable_name IN ('mysql-monitor_connect_interval','mysql-monitor_ping_interval','mysql-monitor_read_only_interval');
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
EOF

sleep 2

echo 'Configuring ProxySQL'
mysql -uadmin -padmin -h 127.0.0.1 -P6032 main < /proxy-sql.sql

echo 'Creating Monitoring user'
#mysql -u root -pmysql -h 127.0.0.1 -P6033 -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'mysql';"
exec proxysql -f $CMDARG