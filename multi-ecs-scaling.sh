#!/bin/bash

upscale() {
    local DESIRED_COUNT=1
    apply_scaling "Upscaling" $DESIRED_COUNT
}

downscale() {
    local DESIRED_COUNT=0
    apply_scaling "Downscaling" $DESIRED_COUNT
}

apply_scaling() {
    local ACTION=$1
    local DESIRED_COUNT=$2

    # print all ECS clusters names with arn
    clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
    echo "$clusters"
    
    # Iterate through each cluster
    for cluster in $clusters; do
        # Fetch cluster name by cluster ARN
        cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
        
        # Print cluster name
        echo "Cluster Name: $cluster_name"

        # Check if the cluster has the required tag
        if aws ecs list-tags-for-resource --resource-arn $cluster --query "tags[?key=='ENV' && value=='demo']" --output text > /dev/null; then
            # Fetch service ARNs of the cluster
            services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)

            # Check if the cluster has services
            if [ -n "$services" ]; then
                # Iterate through each service
                for service in $services; do
                    # Fetch service name by service ARN
                    service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)

                    # upscale/downscale the cluster
                    aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $DESIRED_COUNT > /dev/null
                    aws ecs wait services-stable --cluster $cluster_name --services $service_name > /dev/null
                    echo "  - $service_name"
                done
            else
                echo "No services found in the cluster."
            fi
        else
            echo "The cluster does not have the required tag."
        fi

        echo "------------------------"
    done

    echo "$ACTION completed."
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





















# #!/bin/bash
# # Get all ECS cluster names
# UPSCALE_DESIRED_COUNT=1
# DOWNSCALE_DESIRED_COUNT=0
# upscale() {
#     clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
#     for cluster in $clusters; do
#         cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
#         echo "Cluster Name: $cluster_name"
#         services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)
#         if [ -n "$services" ]; then
#             echo "Services:"
#             for service in $services; do
#                 service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)
#                 aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $UPSCALE_DESIRED_COUNT
#                 aws ecs wait services-stable --cluster $cluster_name --services $service_name
#                 echo "  - $service_name"
#             done
#         else
#             echo "No services found in the cluster."
#         fi
#         echo "------------------------"
#     done
# }
# downscale() {
#     clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
#     for cluster in $clusters; do
#         cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
#         echo "Cluster Name: $cluster_name"
#         services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)
#         if [ -n "$services" ]; then
#             echo "Services:"
#             for service in $services; do
#                 service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)
#                 aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $DOWNSCALE_DESIRED_COUNT
#                 aws ecs wait services-stable --cluster $cluster_name --services $service_name
#                 echo "  - $service_name"
#             done
#         else
#             echo "No services found in the cluster."
#         fi
#         echo "------------------------"
#     done
# }

# # Usage
# if [ "$1" == "upscale" ]; then
#   upscale
# elif [ "$1" == "downscale" ]; then
#   downscale
# else
#   echo "Usage: $0 {upscale|downscale}"
#   exit 1
# fi


