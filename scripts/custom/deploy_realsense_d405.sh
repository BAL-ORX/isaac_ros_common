#!/bin/bash
set -euo pipefail

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
else
    echo "Cannot infer datahub id from hostname '$HOSTNAME' (expected trailing digits)"
    exit 1
fi

hub_num=$((10#$hub_id))
SELF_DATAHUB=$(printf 'datahub_%02d' "$hub_num")

# Set default absolute path for the config file (now dynamic)
default_config_path="/home/$USER/dev/orx/data/experiment_config/${SELF_DATAHUB}/intel_realsense_d405_0"

# Use the first argument as the config path, or the specified default path
config_path="${1:-$default_config_path}"

# Check if the config exists
# - If config_path is a file, use -f
# - If config_path might be a directory (as your default suggests), use -e or -d
if [ ! -e "$config_path" ]; then
    echo "Configuration not found at: $config_path"
    exit 1
fi

docker_name="$(basename "$config_path")"
echo "$docker_name"

docker run --rm -it --gpus all --runtime=nvidia \
    --name "$docker_name" \
    --privileged \
    --network host \
    --cpus 4 \
    -e ROS_DOMAIN_ID=1 \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CYCLONEDDS_URI=/home/admin/cyclone_profile.xml \
    -v "/home/$USER/dev/orx/cyclone_profile.xml:/home/admin/cyclone_profile.xml" \
    -v /dev/input:/dev/input \
    -v "$config_path:/intel_realsense_d405_ros_config.yaml" \
    "girf/orx-middleware-isaac-ros-${PLATFORM_NAME}-realsense_d405"