create database `example-db`;
use `example-db`;
create table person (id int NOT NULL AUTO_INCREMENT,name varchar(255), primary key (id));
insert into `example-db`.person ( name ) values ('jarbas');