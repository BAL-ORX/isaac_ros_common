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