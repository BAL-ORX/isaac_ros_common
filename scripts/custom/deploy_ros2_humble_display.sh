#!/bin/bash

xhost +

# Determine platform architecture
PLATFORM="$(uname -m)"
USER_ID=$(id -u)
GROUP_ID=$(id -g)
DOCKER_USER="admin"
if [[ $PLATFORM == "aarch64" ]]; then
    PLATFORM_NAME="jetson"
elif [[ $PLATFORM == "x86_64" ]]; then
    if [[ $USER_ID == 1001 || $USER_ID == 1000 ]]; then
        PLATFORM_NAME="desktop"
    elif [[ $USER_ID == 1003 ]]; then
        PLATFORM_NAME="dgx"
        DOCKER_USER="orx_user"
    else
        echo "Unsupported user id: $USER_ID"
        exit 1
    fi
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

DOCKER_IMAGE_NAME=girf/orx-middleware-isaac-ros-"$PLATFORM_NAME"-ros2_humble
echo "Running: $DOCKER_IMAGE_NAME with user $DOCKER_USER"

docker run --rm -it --gpus all --runtime=nvidia \
    --privileged \
    --network host \
    -e DISPLAY \
    -e ROS_ROOT=/opt/ros/humble \
    -e ROS_DOMAIN_ID=1 \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CYCLONEDDS_URI=/home/"$DOCKER_USER"/cyclone_profile.xml \
    -v /home/"$USER"/dev/orx/cyclone_profile.xml:/home/"$DOCKER_USER"/cyclone_profile.xml \
    -v /home/"$USER"/dev/orx/data:/home/"$DOCKER_USER"/data \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --user $DOCKER_USER \
    --workdir /home/"$DOCKER_USER" \
    $DOCKER_IMAGE_NAME \
    bash
