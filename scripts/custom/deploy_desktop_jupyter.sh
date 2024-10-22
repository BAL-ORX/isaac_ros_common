docker run --rm -it -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all --runtime=nvidia \
    --network host \
    --privileged \
    -v "/home/vschorp/dev/orx/orx_middleware/ros2_ws:/home/jovyan/work/isaac_ros-dev" \
    --user="jovyan" \
    -p 8888:8888 \
    vschorp98/orx-middleware-isaac-ros-desktop-jupyter \
    bash