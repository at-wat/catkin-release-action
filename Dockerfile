FROM alpineros/alpine-ros:melodic-ros-core

RUN apk add --no-cache \
  git \
  ros-${ROS_DISTRO}-catkin

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
