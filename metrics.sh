#!/bin/bash
# This script send relevant metrics for autoscaling for cloudwatch
# Make this script executable
# Install as crontab on machine that is 24/7 and has IAM Role with:
#   ecs:DescribeServices
#   cloudwatch:PutMetricData
# 
#   To install crontab: $ crontab -u ec2-user -e
# 
#   */1 * * * * PATH=/home/ec2-user/.local/bin /home/ec2-user/metrics.sh

ECS_CLUSTER='boomcredit-dev-cluster'
LOYALTY_SERVICE='dev-loyalty-service-api'
CONEKTA_SERVICE='dev-mx-integration-conekta'
GATEWAY_SERVICE='dev-message-gateway'
STATE_MACHINE_SERVICE='dev-mx-loan-state-machine'
MANAGER_SERVICE='dev-integration-manager'
STP_SERVICE='dev-mx-integration-stp'
API_SERVICE='dev-fineract-api'

LOYALTY_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${LOYALTY_SERVICE} --query 'services[*].runningCount' --output text)
CONEKTA_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${CONEKTA_SERVICE} --query 'services[*].runningCount' --output text)
GATEWAY_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${GATEWAY_SERVICE} --query 'services[*].runningCount' --output text)
STATE_MACHINE_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${STATE_MACHINE_SERVICE} --query 'services[*].runningCount' --output text)
MANAGER_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${MANAGER_SERVICE} --query 'services[*].runningCount' --output text)
STP_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${STP_SERVICE} --query 'services[*].runningCount' --output text)
API_RUNNING_COUNT=$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${API_SERVICE} --query 'services[*].runningCount' --output text)

aws cloudwatch put-metric-data --metric-name loyalty-running-count --dimensions Service=${LOYALTY_SERVICE}  --namespace "custom/autoscaling" --value ${LOYALTY_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name conekta-running-count --dimensions Service=${CONEKTA_SERVICE}  --namespace "custom/autoscaling" --value ${CONEKTA_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name gateway-running-count --dimensions Service=${GATEWAY_SERVICE}  --namespace "custom/autoscaling" --value ${GATEWAY_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name state-machine-running-count --dimensions Service=${STATE_MACHINE_SERVICE}  --namespace "custom/autoscaling" --value ${STATE_MACHINE_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name manager-running-count --dimensions Service=${MANAGER_SERVICE}  --namespace "custom/autoscaling" --value ${MANAGER_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name stp-running-count --dimensions Service=${STP_SERVICE}  --namespace "custom/autoscaling" --value ${STP_RUNNING_COUNT}
aws cloudwatch put-metric-data --metric-name api-running-count --dimensions Service=${API_SERVICE}  --namespace "custom/autoscaling" --value ${API_RUNNING_COUNT}