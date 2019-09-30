DELETE FROM mysql_servers;
INSERT INTO mysql_servers (hostgroup_id,hostname,port,max_replication_lag) VALUES (0,'{{ sql:writer-node }}',{{ sql:port }},1);
INSERT INTO mysql_servers (hostgroup_id,hostname,port,max_replication_lag) VALUES (1,'{{ sql:reader-node }}',{{ sql:port }},1);
DELETE FROM mysql_replication_hostgroups;
INSERT INTO mysql_replication_hostgroups (writer_hostgroup,reader_hostgroup,check_type) VALUES (0,1,'read_only');

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

DELETE FROM mysql_users;
INSERT INTO mysql_users (username,password,active,default_hostgroup) values ('{{ sql:user }}','{{ sql:password }}',1,0);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK; 

SET @long_query = '^select l.id as id, l.account_no as accountNo'                   

DELETE FROM mysql_query_rules;
INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply) VALUES (1,1,@long_query,1,1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

UPDATE global_variables SET variable_value='admin:admin;radmin:radmin' WHERE variable_name='admin-admin_credentials';
UPDATE global_variables SET variable_value='0.0.0.0:6032' WHERE variable_name='admin-mysql_ifaces';
UPDATE global_variables SET variable_value='{{ sql:user }}' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='{{ sql:password }}' WHERE variable_name='mysql-monitor_password';
UPDATE global_variables SET variable_value='2000' WHERE variable_name IN ('mysql-monitor_connect_interval','mysql-monitor_ping_interval','mysql-monitor_read_only_interval');
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;



