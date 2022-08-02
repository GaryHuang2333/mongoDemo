#!/bin/bash

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

build_new_image() {
  local imageName=$1
  local dockerFile=$2
  echo "#### build image $imageName with $dockerFile"
  docker build -t $imageName --rm=true -f $dockerFile .
}

build_with_existing_image() {
  local imageName=$1
  local dockerFile=$2
  docker pull mongo:latest
}

remove_old_container() {
  local containerPrefix=$1

  echo "#### stop & delete old container with prefix $containerPrefix"
  docker stop `docker ps -aq -f "name=$containerPrefix*"`
  docker rm `docker ps -aq -f "name=$containerPrefix*"`
}

do_run_image() {
  local imageName=$1
  local containername=$2

  echo "#### begin run image $imageName as $containername"
  docker run -d --name $containername $imageName
}

health_check_running_container() {
  local containerPrefix=$1

  echo "#### health_check_running_container "
  docker ps -a -f "name=$containerPrefix*"
}

run_image() {
  local containerPrefix=$1
  local imageName=$2
  local containername=$3

  health_check_running_container $containerPrefix
  remove_old_container $containerPrefix
  do_run_image $imageName $containername
  health_check_running_container $containerPrefix
}

run_with_original_image() {
    local containerPrefix=$1
    local imageName=$2
    local containername=$3
    docker run -d --name myMongoContainer -p 8081:27017 -v `pwd`/config/mongod.conf:/mongo/mongod.conf -v `pwd`/db:/var/lib/mongodb -v `pwd`/mongoLogs:/var/log/mongodb mongo:latest --config /mongo/mongod.conf
}

mongosh_connection_mongosh() {
  local containername=$1

  echo "#### begin mongosh connection with $containername "
  docker exec -it $containername mongosh
}

mongosh_connection_bash() {
  local containername=$1

  echo "#### begin bash connection with $containername "
  docker exec -it $containername bash
}

mongo_configRS_build() {
  echo "# begin build image"
  docker build -t gary/mongo_configrs:0.1 --rm=true -f MongoConfigServer.dockerfile .
  echo "# begin run image"
  docker run -d --name myMC_mongo_configrs_1 gary/mongo_configrs:0.1
}

# prepare parameters and variables
action=$1
imageVersion=0.1
writer=gary
appname=mongo
imageName=gary/mongo
imageTageName=$imageName:$imageVersion
host_port=9000
dockerfile=MongoDockerfile
containerNamePrefix=my
containerName="$containerNamePrefix"_"$writer"_"$appname"_"$imageVersion"
if [[ "$action" == "build_new_image" ]]; then
  build_new_image $imageTageName $dockerfile;
elif [[ "$action" == "build" ]]; then
  build_with_existing_image $imageTageName $dockerfile;
elif [[ "$action" == "run" ]]; then
  run_image $containerNamePrefix $imageTageName $containerName
elif [[ "$action" == "run_with_original_image" ]]; then
  remove_old_container $containerNamePrefix
  run_with_original_image $containerNamePrefix $imageTageName $containerName
elif [[ "$action" == "status" ]]; then
  health_check_running_container $containerNamePrefix
elif [[ "$action" == "mongosh" ]]; then
  mongosh_connection_mongosh $containerName
elif [[ "$action" == "it" ]]; then
  mongosh_connection_bash $containerName
elif [[ "$action" == "start_configRS" ]]; then
  mongo_configRS_build
elif [[ "$action" == "remove" ]]; then
  remove_old_container $containerNamePrefix
else
  echoRed "Usage: $0 {build|run|mongosh|it}"; exit 1;
fi







