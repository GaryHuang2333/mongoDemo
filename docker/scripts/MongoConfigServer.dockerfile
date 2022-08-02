FROM mongo:latest
# refer to https://github.com/docker-library/mongo/blob/master/5.0/Dockerfile
MAINTAINER Gary Huang
# prepare
# 2.install vim for vm
RUN apt-get update
RUN && apt-get install vim
RUN && apt-get install less

# for setup configserver
ENV REPLICA_NAME="myConfigRS"
ENV MONGO_CONFIG_SOURCE="./config/mongoConfigRS.conf"
ENV MONGO_CONFIG_DESTINATION="/etc/mongoConfigRS.conf"
ADD MONGO_CONFIG_SOURCE MONGO_CONFIG_DESTINATION
RUN sed -i 's/{replSetName}/REPLICA_NAME/g' MONGO_CONFIG_DESTINATION
WORKDIR ~
RUN mongod --config MONGO_CONFIG_DESTINATION

# after all configServer startup :
# 1. add ip&hostname to each configServer /etc/hosts, then then can talk to each other
# 2. config replica set in 1 configServer member and health check RS status

EXPOSE 27017
CMD mongosh




