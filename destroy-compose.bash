#!/bin/bash

. colors


printf "$BRIGHT"
printf "##################################################################################\n"
printf "# Stopping ProxySQL for $ENV environment!                                        #\n"
printf "##################################################################################\n"
printf "$NORMAL"

docker-compose stop
docker-compose rm -f
docker volume prune -f
docker network prune -f
printf "$POWDER_BLUE$BRIGHTDeprovisioning COMPLETE!$NORMAL\n"