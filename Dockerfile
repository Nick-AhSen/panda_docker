# Existing official ROS Melodic/Ubuntu 18.04 docker image
FROM ros:melodic-ros-core-bionic

# Install some useful basics
RUN apt-get update && \
    apt-get install -y \
      curl \
      build-essential \
      cmake \
      software-properties-common \
      psmisc \
      htop \
      mesa-utils \
      git-all \
      nano \
      && \
    rm -rf /var/lib/apt/lists/*

## setup sources.list for ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install ros
RUN apt-get update && apt-get install -y \
    ros-melodic-desktop-full \
    && rm -rf /var/lib/apt/lists/*

ARG WS=/workspace
RUN mkdir -p $WS
WORKDIR $WS

ENV PKG_CONFIG_PATH=/workspace/install/lib/pkgconfig:/workspace/install/share/pkgconfig:$PKG_CONFIG_PATH
ADD .git /workspace/.git

#Install libfranka from source (as an example of how to build/install libraries)
RUN git clone --recursive https://github.com/frankaemika/libfranka && \
    cd $WS/libfranka && \
    rm -rf build && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    cd $WS && rm -rf libfranka/build


# install Panda robot dependencies + any other packages that are needed
RUN apt-get update && \
    apt-get install -q -y \
	ros-melodic-moveit-simple-controller-manager \
	ros-melodic-joint-trajectory-controller \ 
	ros-melodic-robot-state-publisher \
	ros-melodic-moveit-planners-ompl \
	ros-melodic-joint-state-publisher \
	ros-melodic-moveit-simple-controller-manager \
	ros-melodic-xacro \
	ros-melodic-moveit-ros-visualization \
	ros-melodic-gazebo-ros \
	ros-melodic-camera-info-manager \
	ros-melodic-effort-controllers \
	ros-melodic-joint-state-controller \
	ros-melodic-moveit-visual-tools \
	ros-melodic-position-controllers \
	ros-melodic-moveit-commander \
    ros-melodic-gazebo-ros-pkgs \
    ros-melodic-gazebo-ros-control \
    ros-melodic-catkin \
    ros-melodic-usb-cam \
    ros-melodic-rosbridge-suite \
    ros-melodic-tf2-web-republisher \
    python-rosdep \
    python-catkin-tools && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc

# setup entrypoint
COPY ./docker_entrypoint.sh /
ENTRYPOINT ["/docker_entrypoint.sh"]
CMD ["bash"]
