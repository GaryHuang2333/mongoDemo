#!/bin/bash

# var prepare
dockerComposeFile=deployMongoCluster-dockerCompose.yml

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

echoUsage() { echoYellow "Usage: $0 {up|down|clean|check|logs}"; exit 1; }

startLogs() {
  docker compose -f $dockerComposeFile logs --follow --timestamps > ../dockerLogs/deployMongoCluster-dockerCompose.logs &
}

stopLogs() {
  kill -9 $(pgrep -f "$dockerComposeFile logs --follow --timestamps")
}

showLogs(){
  echo "#### showLogs of mongocluster "
  docker compose -f $dockerComposeFile logs
}

up() {
  echo "#### start mongo cluster "
  docker compose -f $dockerComposeFile -p mongocluster up -d
}

down() {
   echo "#### stop mongo cluster "
   docker compose -f $dockerComposeFile down
}

clean() {
  down
  echo "#### clean mongo cluster data, log files"
  rm -rf ../mongoLogs/*
  rm -rf ../dockerLogs/*
  rm -rf ../mongoDBs/*
}

check() {
  echo "#### health check"
  echo "#### compose projects status"
  docker compose ls
  echo "#### running containers status"
  docker ps
  echo "#### networks status"
  docker network ls
}

main() {
  action=$1

  if [[ "$action" == "up" ]]; then
    up;
  elif [[ "$action" == "down" ]]; then
    down;
  elif [[ "$action" == "clean" ]]; then
    clean;
  elif [[ "$action" == "check" ]]; then
    check;
  elif [[ "$action" == "logs" ]]; then
    showLogs;
  else
    echoUsage;
  fi
}

main "$@"

