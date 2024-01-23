#!/bin/bash
# Get all ECS cluster names
UPSCALE_DESIRED_COUNT=1
DOWNSCALE_DESIRED_COUNT=0
upscale() {
    clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
    for cluster in $clusters; do
        cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
        echo "Cluster Name: $cluster_name"
        services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)
        if [ -n "$services" ]; then
            echo "Services:"
            for service in $services; do
                service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)
                aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $UPSCALE_DESIRED_COUNT
                # aws ecs wait services-stable --cluster $cluster_name --services $service_name
                echo "  - $service_name"
            done
        else
            echo "No services found in the cluster."
        fi
        echo "------------------------"
    done
}
downscale() {
    clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
    for cluster in $clusters; do
        cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
        echo "Cluster Name: $cluster_name"
        services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)
        if [ -n "$services" ]; then
            echo "Services:"
            for service in $services; do
                service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)
                aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $DOWNSCALE_DESIRED_COUNT
                # aws ecs wait services-stable --cluster $cluster_name --services $service_name
                echo "  - $service_name"
            done
        else
            echo "No services found in the cluster."
        fi
        echo "------------------------"
    done
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










