#!/bin/bash
set -e

. support

DST_ENV=$1
VAR=$2
__VERBOSE=${VAR:-6}

logger 6 "$BRIGHT"
logger 6 "##################################################################################\n"
logger 6 "# Started ProxySQL for $DST_ENV environment!                                     #\n"
logger 6 "##################################################################################\n"
logger 6 "$NORMAL"



if [ "$DST_ENV" = "local" ]; then
    logger 6 "$POWDER_BLUE Running Stack for $DST_ENV$POWDER_BLUE\n"
    docker-compose up -d
    logger 6 "$YELLOW Waiting write-sql to be created"
    sleep 2
    wait_db 127.0.0.1 3306 root mysql
    logger 6 "\n"
    mysql -h 127.0.0.1 -uradmin -pradmin -P 6032 < proxy-sql/local-config.sql

elif [ "$DST_ENV" = "rds" ];then 
    aws-check
    logger 6 "$POWDER_BLUE Running Stack for $DST_ENV$POWDER_BLUE\n"
    SAMPLE_CONFIG='proxy-sql/rds-sample-config.sql'
    CONFIG_FILE='proxy-sql/rds-config.sql'
    DB_CLUSTER='boomcredit-dev-cluster'
    logger 6 "$GREEN Gathering endopints of $DB_CLUSTER$GREEN\n"
    WRITER_ENDPOINT=$(aws rds describe-db-clusters --db-cluster-identifier $DB_CLUSTER --query 'DBClusters[*].Endpoint' --output text)
    READER_ENDPOINT=$(aws rds describe-db-clusters --db-cluster-identifier $DB_CLUSTER --query 'DBClusters[*].ReaderEndpoint' --output text)
    DB_PORT=$(aws rds describe-db-clusters --db-cluster-identifier $DB_CLUSTER --query 'DBClusters[*].Port' --output text)
    DB_USER='root'
    DB_PASSWORD='F+gFkyjCFtG*7Cu-mNVd'
    logger 6 "$YELLOW RDS writer endopint: $WRITER_ENDPOINT:$DB_PORT$YELLOW\n"
    logger 6 "$YELLOW RDS reader endopint: $READER_ENDPOINT:$DB_PORT$YELLOW\n"
    logger 6 "$POWDER_BLUE Replacing $ENV variables on $SAMPLE_CONFIG$POWDER_BLUE\n"

    sed -e 's@{{ sql:writer-node }}@'"$WRITER_ENDPOINT"'@g' \
        -e 's@{{ sql:reader-node }}@'"$READER_ENDPOINT"'@g' \
        -e 's@{{ sql:port }}@'"$DB_PORT"'@g' \
        -e 's@{{ sql:user }}@'"$DB_USER"'@g' \
        -e 's@{{ sql:password }}@'"$DB_PASSWORD"'@g' $SAMPLE_CONFIG > $CONFIG_FILE
    
    #docker-compose evaluates DST_ENV=rds to select proper config file, if DST_ENV is empty the default is local-config.sql
    export DST_ENV
    docker-compose up --build -d proxy-sql
    wait_db 127.0.0.1 6032 radmin radmin
    mysql -h 127.0.0.1 -uradmin -pradmin -P 6032 < $CONFIG_FILE
    
    logger 7 "$(docker commit -m="ProxySQL for RDS with configuration from $CONFIG_FILE" $(docker ps -a -q -f name=proxy-sql) boomcredit/proxy-sql:latest)\n"
    docker-compose down
    logger 6 "$GREEN Docker image boomcredit/proxy-sql:latest build locally$GREEN\n"

    logger 6 "$POWDER_BLUE Login to AWS ECR $POWDER_BLUE"
    $(aws ecr get-login --no-include-email)

    logger 6 "$POWDER_BLUE Pushing image to registry $POWDER_BLUE"
    docker tag boomcredit/proxy-sql:latest 212568053769.dkr.ecr.us-east-1.amazonaws.com/boomcredit/proxy-sql:latest
    docker push 212568053769.dkr.ecr.us-east-1.amazonaws.com/boomcredit/proxy-sql:latest

    #STACK_NAME='demo'
    #STACK_ARN=$(aws cloudformation update-stack --stack-name demo --template-body file://cloudformation/ecs-cluster.yml --capabilities CAPABILITY_IAM --parameters ParameterKey=ProxySQLContainerImage,ParameterValue=212568053769.dkr.ecr.us-east-1.amazonaws.com/boomcredit/proxy-sql:latest --output text)
    #logger 6 "$POWDER_BLUE Creating stack $STCK_NAME, ARN= $STACK_ARN$POWDER_BLUE\n"


else
    printf "$RED Sorry invalid option...$RED\n"
    printf "Usage:\n"
    printf "./init-compose.bash \$ENV \$LOG_LEVEL\n\n"
    printf "ENV = local | rds\n"
    printf "LOG_LEVEL [0]=emerg [1]=alert [2]=crit [3]=err [4]=warning [5]=notice [6]=info [7]=debug\n\n"
fi

