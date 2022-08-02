#!/bin/bash

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

echoUsage() { echoRed "Usage: $0 {check_containers|check_images|remove|run_configServers|run_mongodS0|run_mongodS1|run_mongodS2|run_mongos|config_configRS}"; exit 1; }

check_containers() {
  echo "#### check_containers "
  docker ps -a
}

check_images() {
  echo "#### check_images "
  docker images
}

remove_network() {
  local prefix=$1

  echo "#### remove network with prefix \"$prefix\" "
  docker network rm `docker network ls -q --filter "name=$prefix"`
}


remove_containers() {
  local prefix=$1

  echo "#### stop & remove container with prefix \"$prefix\" "
  docker stop `docker ps -aq -f "name=$prefix*"`
  docker rm `docker ps -aq -f "name=$prefix*"`
}



remove_files() {
  local dbPath=`pwd`/../mongoDBs
  local logPath=`pwd`/../mongoLogs

  echo "#### remove_files under $dbPath"
  cd $dbPath; rm -rf *;
  echo "#### remove_files under $logPath"
  cd $logPath; rm -rf *;
}

setup_host() {
  local hosts=("$@")
  local addresses=();
  local hostnamef=();

  ## get hostname
  for (( i=0; i<${#hosts[@]}; i++ )); do
    addresses[i]=$(docker exec "${hosts[i]}" bash -c "hostname -I");
    hostnamef[i]=$(docker exec "${hosts[i]}" bash -c "hostname -f");
  done

  ## add hostname to each member
  echo "## add hostname to each member "
  for (( i=0; i<${#hosts[*]}; i++ )); do
    for (( j=0; j<${#hosts[*]}; j++ )); do
      docker exec "${hosts[i]}" bash -c "echo -e '${addresses[j]} ${hosts[j]}' >> /etc/hosts"
      docker exec "${hosts[i]}" bash -c "echo -e '${addresses[j]} ${hostnamef[j]}' >> /etc/hosts"
    done
  done

  ## health check hosts
  echo "## health check hosts"
  for (( i=0; i<${#hosts[*]}; i++ )); do
    docker exec "${hosts[i]}" bash -c "echo ${hosts[i]}; cat /etc/hosts"
  done
}


create_network() {
  local networkName=$1

  echo "#### create_network '$networkName'"
  docker network create "$networkName";
}

run_configInstance() {
  local containerName=$1
  local port=$2
  local configPath=$3
  local dbPath=$4
  local logPath=$5
  local networkName=$6
  local shardName=$7

  docker run -d --name $containerName -p $port:27017 \
    --network $networkName \
    -v $dbPath:/var/lib/mongodb \
    -v $logPath:/var/log/mongodb \
    mongo --configsvr --replSet $shardName --bind_ip localhost,$containerName --logpath /var/log/mongodb/mongod.log --dbpath /var/lib/mongodb
}

run_configServers() {
  echo "#### run_configServers"
  local networkName=$1
  local shardName=myConfigsRS
  local containerNames=("myMongoConfig1" "myMongoConfig2" "myMongoConfig3")
  local port=(9001 9002 9003)
  local configPath=`pwd`/../mongoConfigs/mongoConfig.conf
  local dbPath=`pwd`/../mongoDBs
  local logPath=`pwd`/../mongoLogs

  for (( i=0; i<${#containerNames[@]}; i++ )); do
    run_configInstance ${containerNames[i]} ${port[i]} $configPath $dbPath/${containerNames[i]} $logPath/${containerNames[i]} $networkName $shardName
  done

#  echo "#### setup_host"
#  setup_host "${containerNames[@]}"
}

config_configRS() {
  echo "#### config_configRS"

  local containerNames=("myMongoConfig1" "myMongoConfig2" "myMongoConfig3")
  setup_host "${containerNames[@]}"


# rs.initiate({_id: "myConfigsRS", configsvr: true, members: [{_id: 0, host: "myMongoConfig1:27017"}, {_id: 1, host: "myMongoConfig2:27017"}, {_id: 2, host: "myMongoConfig3:27017"}]});
# rs.initiate({_id: "myConfigsRS", configsvr: true, members: [{_id: 0, host: "6c5fee9aa0c7:27017"}, {_id: 1, host: "46714085f105:27017"}, {_id: 2, host: "dc473619a21e:27017"}]});
# rs.initiate({_id: "myConfigsRS", configsvr: true, members: [{_id: 0, host: "172.17.0.2:27017"}, {_id: 1, host: "172.17.0.3:27017"}, {_id: 2, host: "172.17.0.4:27017"}]});
# rs.conf();
# rs.status();


# rs.initiate({_id: "myMongdS0", members: [{_id: 0, host: "myMongodS0N1:27017"}, {_id: 1, host: "myMongodS0N2:27017"}, {_id: 2, host: "myMongodS0N3:27017"}]});
# rs.initiate({_id: "myMongdS0", members: [{_id: 0, host: "myMongodS0N1:9101"}, {_id: 1, host: "myMongodS0N2:9102"}, {_id: 2, host: "myMongodS0N3:9103"}]});
# rs.initiate({_id: "myMongodS0", members: [{_id: 0, host: "myMongodS0N1:27017"}, {_id: 1, host: "myMongodS0N2:27017"}, {_id: 2, host: "myMongodS0N3:27017"}]});

# rs.initiate({_id: "myRS", members: [{_id: 0, host: "myMongoContainer1:27017"}, {_id: 1, host: "myMongoContainer2:27017"}, {_id: 2, host: "myMongoContainer3:27017"}]});


# 172.17.0.2  myMongoConfig1
# 172.17.0.2  6c5fee9aa0c7
# 172.17.0.3  myMongoConfig2
# 172.17.0.3  46714085f105
# 172.17.0.4  myMongoConfig3
# 172.17.0.4  dc473619a21e

# apt-get update
# apt-get install net-tools
# ifconfig
  echo ""
}

run_mongodInstance() {
  local containerName=$1
  local port=$2
  local configPath=$3
  local dbPath=$4
  local logPath=$5
  local networkName=$6
  local shardName=$7

# failed with "No host described in new configuration"
#  docker run -d --name $containerName -p $port:27017 \
#    -v $configPath:/mongo/mongod.conf \
#    -v $dbPath:/var/lib/mongodb \
#    -v $logPath:/var/log/mongodb \
#    mongo --config /mongo/mongod.conf

  docker run -d --name $containerName -p $port:27017 \
    --network $networkName \
    -v $dbPath:/var/lib/mongodb \
    -v $logPath:/var/log/mongodb \
    mongo mongod --replSet $shardName --bind_ip localhost,$containerName --logpath /var/log/mongodb/mongod.log --dbpath /var/lib/mongodb
}

run_mongodRS() {
  local shardNo=$1
  local shardName="myMongodS"$shardNo
  local networkName=$2
  echo "#### run_mongodRS for shard$shardNo"

  local containerNames=("myMongodS"$shardNo"N1" "myMongodS"$shardNo"N2" "myMongodS"$shardNo"N3")
  local port=(91"$shardNo"1 91"$shardNo"2 91"$shardNo"3)
  local configPath=`pwd`/../mongoConfigs/mongodS"$shardNo".conf
  local dbPath=`pwd`/../mongoDBs
  local logPath=`pwd`/../mongoLogs

  for (( i=0; i<${#containerNames[@]}; i++ )); do
    run_mongodInstance ${containerNames[i]} ${port[i]} $configPath $dbPath/${containerNames[i]} $logPath/${containerNames[i]} $networkName $shardName
  done

#  echo "#### setup_host"
#  setup_host "${containerNames[@]}"
}

run_mongoS() {
  echo "#### run_mongoS"

  local containerName="myMongoS"
  local port=8081
  local configPath=`pwd`/../mongoConfigs/mongos.conf
  local logPath=`pwd`/../mongoLogs

  docker run -d --name $containerName -p $port:27017 \
    -v $configPath:/mongo/mongod.conf \
    -v $logPath:/var/log/mongodb \
    mongo:latest --config /mongo/mongod.conf
}


main() {
  action=$1
  # predefine variables
  containerNamePrefix=my
  networkName=myMongoClusterNetwork

  # health check running container
  if [[ "$action" == "check_containers" ]]; then
    check_containers;
  # health check build images
  elif [[ "$action" == "check_images" ]]; then
    check_images;
  # remove running container
  elif [[ "$action" == "remove" ]]; then
    remove_containers $containerNamePrefix;
    remove_network $containerNamePrefix;
    remove_files;
  # run mongo config replica set
  elif [[ "$action" == "run_configServers" ]]; then
    create_network $networkName;
    run_configServers $networkName;
  # run shard0 mongod replica set
  elif [[ "$action" == "run_mongodS0" ]]; then
    create_network $networkName;
    run_mongodRS 0 $networkName;
  # run shard1 mongod replica set
  elif [[ "$action" == "run_mongodS1" ]]; then
    create_network $networkName;
    run_mongodRS 1 $networkName;
  # run shard2 mongod replica set
  elif [[ "$action" == "run_mongodS2" ]]; then
    create_network $networkName;
    run_mongodRS 2 $networkName;
  # run 1 mongos
  elif [[ "$action" == "run_mongos" ]]; then
    run_mongoS;
  # config_configRS
  elif [[ "$action" == "config_configRS" ]]; then
    config_configRS;
  else
    echoUsage;
  fi
}

main "$@"



#Test from https://gitee.com/GaryHuang2333/WorkingNotes/blob/master/DockerMongoClusterNotes.txt
#
## shard0
#docker network create myMongoClusterNetwork
#docker run -d --name myMongodS0N1 -p 9101:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS0N1:/mongo/data -v `pwd`/../mongoLogs/mongodS0N1:/mongo/log mongo --replSet mongodS0 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log
#docker run -d --name myMongodS0N2 -p 9102:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS0N2:/mongo/data -v `pwd`/../mongoLogs/mongodS0N2:/mongo/log mongo --replSet mongodS0 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log
#docker run -d --name myMongodS0N3 -p 9103:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS0N3:/mongo/data -v `pwd`/../mongoLogs/mongodS0N3:/mongo/log mongo --replSet mongodS0 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log
#docker inspect `docker ps -aqf "name=myMongodS0N1"`|grep IPAddress 172.29.0.2
#docker inspect `docker ps -aqf "name=myMongodS0N2"`|grep IPAddress 172.29.0.3
#docker inspect `docker ps -aqf "name=myMongodS0N3"`|grep IPAddress 172.29.0.4
#docker exec -it myMongodS0N1 mongosh
#rs.initiate({_id: "mongodS0", members: [{_id: 0, host: "172.29.0.2:27017"}, {_id: 1, host: "172.29.0.3:27017"}, {_id: 2, host: "172.29.0.4:27017"}]});
#
##shard1
#docker run -d --name myMongodS1N1 -p 9201:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS1N1:/mongo/data -v `pwd`/../mongoLogs/mongodS1N1:/mongo/log mongo --replSet mongodS1 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker run -d --name myMongodS1N2 -p 9202:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS1N2:/mongo/data -v `pwd`/../mongoLogs/mongodS1N2:/mongo/log mongo --replSet mongodS1 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker run -d --name myMongodS1N3 -p 9203:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/mongodS1N3:/mongo/data -v `pwd`/../mongoLogs/mongodS1N3:/mongo/log mongo --replSet mongodS1 --shardsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker inspect `docker ps -aqf "name=myMongodS1N1"`|grep IPAddress;  172.29.0.5
#docker inspect `docker ps -aqf "name=myMongodS1N2"`|grep IPAddress;  172.29.0.6
#docker inspect `docker ps -aqf "name=myMongodS1N3"`|grep IPAddress;  172.29.0.7
#docker exec -it myMongodS1N1 mongosh
#rs.initiate({_id: "mongodS1", members: [{_id: 0, host: "172.29.0.5:27017"}, {_id: 1, host: "172.29.0.6:27017"}, {_id: 2, host: "172.29.0.7:27017"}]});
#
## configRS
#docker run -d --name myConfig1 -p 9001:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/config1:/mongo/data -v `pwd`/../mongoLogs/config1:/mongo/log mongo --replSet rsconfig --configsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker run -d --name myConfig2 -p 9002:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/config2:/mongo/data -v `pwd`/../mongoLogs/config2:/mongo/log mongo --replSet rsconfig --configsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker run -d --name myConfig3 -p 9003:27017 --network myMongoClusterNetwork -v `pwd`/../mongoDBs/config3:/mongo/data -v `pwd`/../mongoLogs/config3:/mongo/log mongo --replSet rsconfig --configsvr --port 27017 --dbpath /mongo/data --logpath /mongo/log/mongod.log ;
#docker inspect `docker ps -aqf "name=myConfig1"`|grep IPAddress;  172.29.0.8
#docker inspect `docker ps -aqf "name=myConfig2"`|grep IPAddress;  172.29.0.9
#docker inspect `docker ps -aqf "name=myConfig3"`|grep IPAddress;  172.29.0.10
#docker exec -it myConfig1 mongosh
#rs.initiate({_id: "rsconfig", members: [{_id: 0, host: "172.29.0.8:27017"}, {_id: 1, host: "172.29.0.9:27017"}, {_id: 2, host: "172.29.0.10:27017"}]});
#
## mongos
##docker run -d --name myMongoS_1 -p 8081:27018 --network myMongoClusterNetwork mongo --bind_ip 0.0.0.0
#docker run -d --name myMongoS_1 -p 8081:27018 --network myMongoClusterNetwork mongo
#docker exec -it myMongoS_1 bash
##mongos --configdb rsconfig/172.29.0.8:27017,172.29.0.9:27017,172.29.0.10:27017 --port 27018 --bind_ip 0.0.0.0
#mongos --configdb rsconfig/172.29.0.8:27017,172.29.0.9:27017,172.29.0.10:27017 --port 27018
#
#docker exec -it myMongoS_1 mongosh --port 27018
#use mongodb
#sh.addShard("mongodS0/172.29.0.2:27017,172.29.0.3:27017,172.29.0.4:27017")
#sh.addShard("mongodS1/172.29.0.5:27017,172.29.0.6:27017,172.29.0.7:27017")

