#!/bin/bash

ECS_CLUSTER_NAME="scaling-cluster1"
ECS_SERVICE_NAME="scaling-service"
UPSCALE_DESIRED_COUNT=1
DOWNSCALE_DESIRED_COUNT=0

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
if [ "$1" == "upscale" ]; then
  upscale
elif [ "$1" == "downscale" ]; then
  downscale
else
  echo "Usage: $0 {upscale|downscale}"
  exit 1
fi
