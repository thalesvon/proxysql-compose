#!/bin/bash

. colors

ENV=$1

printf "$BRIGHT"
printf "##################################################################################\n"
printf "# Started ProxySQL for $ENV environment!                                        #\n"
printf "##################################################################################\n"
printf "$NORMAL"


if [ "$ENV" = "local" ]; then
    printf "$POWDER_BLUE Running Stack for $ENV$POWDER_BLUE\n"
    docker-compose up -d
    printf "$YELLOW Waiting write-sql to be created"
    RC=1
    while [ $RC -eq 1 ]
    do
    sleep 1
    printf "."
    mysqladmin ping -h127.0.0.1 -P3306 -uroot -pmysql > /dev/null 2>&1
    RC=$?
    done
    mysql -h 127.0.0.1 -uradmin -pradmin -P 6032 < proxy-sql/config.sql

elif [ "$ENV" = "dev" ];then 
    printf "$POWDER_BLUE Running Stack for $ENV$POWDER_BLUE\n"
    printf " TODO substitute variables on config.sql\n"
else
    printf "$RED Sorry invalid option...$RED\n"
    printf "Usage:\n"
    printf "./init-compose.bash local | dev\n\n"
fi

