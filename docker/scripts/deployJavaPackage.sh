#!/bin/bash

# default vars
imageName=gary/mongodemo:0.1
host_port=8888
dockerfile=deployJavaPackage.dockerfile
containerName=myMongoDemoJar

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }
echoUsage() { echoYellow "Usage: $0 {start|stop|deploy|clean|check}"; exit 1; }

check() {
  echo "#### health check"
  docker ps
}

start() {
  echo "## start image $imageName for container $containerName"
  docker run -d -p $host_port:8080 --name $containerName $imageName
}

stop() {
  echo "#### stop container $containerName"
  docker stop `docker ps -aq -f "name=$containerName"`
}

clean() {
  stop
  echo "#### clean container $containerName"
  docker rm `docker ps -aq -f "name=$containerName"`
}

deploy() {
  clean;
  echo "#### prepare jar"
  mvn clean package -f ../../pom.xml

  echo "## build image $imageName"
  docker build -t $imageName --rm=true -f $dockerfile ../../target
}

main() {
  action=$1

  if [[ "$action" == "start" ]]; then
    start;
  elif [[ "$action" == "deploy" ]]; then
    deploy;
    start;
  elif [[ "$action" == "stop" ]]; then
    stop;
  elif [[ "$action" == "clean" ]]; then
    clean;
  elif [[ "$action" == "check" ]]; then
    check;
  else
    echoUsage;
  fi
}

main "$@"


