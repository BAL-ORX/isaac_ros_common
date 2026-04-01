#!/bin/bash

xhost +

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

echo "platform is $PLATFORM"

sudo docker run --rm -it --gpus all --runtime=nvidia \
    --privileged \
    --network host \
    -e ROS_ROOT=/opt/ros/humble \
    -e ROS_DOMAIN_ID=1 \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CYCLONEDDS_URI=/home/jovyan/cyclone_profile.xml \
    -v /home/$USER/dev/orx/cyclone_profile.xml:/home/jovyan/cyclone_profile.xml \
    -v /home/$USER/data:/home/jovyan/data \
    --user jovyan \
    --workdir /home/jovyan \
    girf/orx-middleware-isaac-ros-"$PLATFORM_NAME"-jupyter \
    bash