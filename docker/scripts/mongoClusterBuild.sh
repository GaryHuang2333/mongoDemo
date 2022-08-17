#!/bin/bash

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

echoUsage() { echoYellow "Usage: $0 {up|down|clean|check}"; exit 1; }

up() {
  echo "#### start mongo cluster "
  docker compose -f docker-compose.yml up -d
}

down() {
   echo "#### stop mongo cluster "
   docker compose -f docker-compose.yml down
}

clean() {
  down
  echo "#### clean mongo cluster data, log files"
  rm -rf ../mongoLogs/*
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
  else
    echoUsage;
  fi
}

main "$@"

