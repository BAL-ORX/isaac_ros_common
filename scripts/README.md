# Isaac ROS Dev Build Scripts

## External workspace
For Jetson or x86_64:
  `run_dev.sh` creates a dev environment with ROS 2 installed. By default, the directory `/workspaces/isaac_ros-dev` in the container is mapped from `~/workspaces/isaac_ros-dev` on the host machine if it exists OR the current working directory from where the script was invoked otherwise. The host directory the container maps to can be explicitly set by running the script with the desired path as the first argument:
  `run_dev.sh -d <path to workspace>`

  In this case, an `.isaac_ros_common-config` file may be placed in the user's $HOME directory, which points to this workspace

## External projects
The `run_dev.sh` and `docker_deploy.sh` scripts may be run from within an external directory. This is typically useful when you have multiple workspaces on your computer and wish to run or deploy them individually. 
Concnretely, this enables building the deployment image for for a package based on the VSCode Devcontainer extension (see the [BAL-ORX/middleware_devcontainer](https://gitlab.uzh.ch/BAL-ORX/middleware_devcontainer) project). 

In this case, it will look for an `.isaac_ros_common-config` file in the current working directory, which will take precedence over all other configurations. 