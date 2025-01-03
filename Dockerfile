FROM ros:noetic-ros-base-focal

# expose ROS port (not sure if this is needed)
# EXPOSE 11311

# keep our image updated
RUN apt-get update && apt-get upgrade -y

# download SLAMWARE SDK
RUN apt-get install -y tar gzip
WORKDIR /opt
ADD https://bucket-download.slamtec.com/2e220e9a22c30898526de308f88df544b17fde9f/slamware_ros_sdk_linux-x86_64-gcc9.tar.gz /opt/slamware.tar.gz
RUN tar xzf slamware.tar.gz
RUN rm -f slamware.tar.gz && mv slamware_ros_sdk_linux-x86_64-gcc9 slamware_ws

# build workspace
ENV ROS_WS=/opt/slamware_ws
WORKDIR $ROS_WS
COPY ./src ./src
RUN /bin/bash -c '. /opt/ros/$ROS_DISTRO/setup.bash; cd $ROS_WS; rosdep install --from-paths src --ignore-src -y; catkin_make'

# clean up
RUN rm -rf /var/lib/apt/lists/*

# set up entry point
RUN sed --in-place --expression '$isource "$ROS_WS/devel/setup.bash"' /ros_entrypoint.sh
RUN sed --in-place --expression '$iexport ROS_IP=\$(hostname -i)' /ros_entrypoint.sh
CMD ["roslaunch", "slamware_launch", "rplidar_start.launch"]