#!/bin/bash

ECS_CLUSTER_NAME="ecs-cluster-name"
ECS_SERVICE_NAME="ecs-service-name"
UPSCALE_DESIRED_COUNT=3
DOWNSCALE_DESIRED_COUNT=1

upscale() {
  aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --desired-count $UPSCALE_DESIRED_COUNT
  aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
  echo "Service upscaled to $UPSCALE_DESIRED_COUNT tasks."
}

downscale() {
  aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --desired-count $DOWNSCALE_DESIRED_COUNT
  aws ecs wait services-stable --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME
  echo "Service downscaled to $DOWNSCALE_DESIRED_COUNT tasks."
}

# Usage
if [ "$2" == "upscale" ]; then
  upscale
elif [ "$1" == "downscale" ]; then
  downscale
else
  echo "Usage: $0 {upscale|downscale}"
  exit 1
fi
