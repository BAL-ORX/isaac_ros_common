#!/bin/bash

# Determine platform architecture
PLATFORM="$(uname -m)"
if [[ $PLATFORM == "aarch64" ]]; then
    PLATFORM_NAME="jetson"
elif [[ $PLATFORM == "x86_64" ]]; then
    PLATFORM_NAME="desktop"
else
    echo "Unsupported platform: $PLATFORM"
    exit 1
fi

HOSTNAME="$(hostname -s | tr -d '[:space:]')"
if [[ "$HOSTNAME" =~ ([0-9]+)$ ]]; then
    hub_id="${BASH_REMATCH[1]}"   # e.g. "09"
    hub_num=$((10#$hub_id))
    SELF_DATAHUB=$(printf 'datahub_%02d' "$hub_num")
else
    echo "Cannot infer datahub id from hostname '$HOSTNAME', using hostname as SELF_DATAHUB"
    SELF_DATAHUB="$HOSTNAME"
fi

# Set default absolute path for the config file
default_config_path="/home/$USER/dev/orx/data/experiment_config/${SELF_DATAHUB}/azure_kinect_1"

# Use the first argument as the config path, or the specified default path
config_path="${1:-$default_config_path}"

# Check if the config file exists
if [ ! -f "$config_path" ]; then
    echo "Configuration file not found at: $config_path"
    exit 1
fi

docker_name=$(basename ${config_path})

docker run -it --rm --gpus 'all' --runtime=nvidia \
    --privileged \
    --network host \
    --cpus 4 \
    -e ROS_DOMAIN_ID=1 \
    -v /dev:/dev \
    -e CYCLONEDDS_URI=/home/admin/cyclone_profile.xml \
    -v /home/"$USER"/dev/orx/cyclone_profile.xml:/home/admin/cyclone_profile.xml \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CONFIG_PATH=/azure_kinect_1 \
    -v "$config_path":/azure_kinect_1 \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name $docker_name \
    girf/orx-middleware-isaac-ros-"$PLATFORM_NAME"-kinect
