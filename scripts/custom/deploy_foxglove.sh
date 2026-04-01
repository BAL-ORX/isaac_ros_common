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

docker_name=foxglove

docker run --rm -it --gpus all --runtime=nvidia \
    --name $docker_name \
    --privileged \
    --network host \
    -e ROS_ROOT=/opt/ros/humble \
    -e ROS_DOMAIN_ID=1 \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CYCLONEDDS_URI=/home/admin/cyclone_profile.xml \
    -v /home/$USER/dev/orx/cyclone_profile.xml:/home/admin/cyclone_profile.xml \
    -p 8765:8765 \
    girf/orx-middleware-isaac-ros-"$PLATFORM_NAME"-foxglove

    # https://app.foxglove.dev/balgrist-orx/dashboard