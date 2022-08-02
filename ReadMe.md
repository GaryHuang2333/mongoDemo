This project is used for mongoDB cluster demo

#1 pull latest mongo image
```bash
# docker pull [OPTIONS] NAME[:TAG|@DIGEST]
docker pull mongo:latest
```

#2 run mongo image
```bash
# docker run [OPTIONS] IMAGE[:tag] [COMMAND] [ARG...]
docker run -itd --name myMongoContainer -p 8081:27017 mongo:latest --auth
docker run -itd --name myMongoContainer -p 8081:27017 mongo --auth  # same as above
```
- -it : --interactive, --tty. Instructs Docker to allocate a pseudo-TTY connected to the container’s stdin
- -d : -detach. Run container in background and print container ID
- --name : Assign a name "myMongoContainer" to the container
- -p : --publish. <host_port>:<container_port>. Bind host_port 27017 to container_port 27017
- --auth：should be mongo arguments. 需要密码才能访问容器的mongoDB服务  


#3 添加用户和设置密码，并且尝试连接。 
```bash
# docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
docker exec -it myMongoContainer mongo admin # mongo shell is deprecated, perfer to mongosh 
docker exec -it myMongoContainer mongosh admin
```
- -it : --interactive, --tty. Instructs Docker to allocate a pseudo-TTY connected to the container’s stdin
- mongo admin : connect to mongoDB instance in container with admin db
```bash
# 创建一个名为 admin，密码为 123456 的用户。
> db.createUser({ user:'admin',pwd:'admin',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
# 尝试使用上面创建的用户信息进行连接。
> db.auth('admin', 'admin')
# change password
> use admin
> db.changeUserPassword("admin", "admin")
```
- mongodb_cmd - db.createUser(user, writeConcern) :
- user json object :
```json
{
   "user":"admin",
   "pwd":"admin",
   "roles":[
      {
         "role":"userAdminAnyDatabase",
         "db":"admin"
      },
      "readWriteAnyDatabase"
   ]
}
```
#4 简单插入几条数据到测试数据库
```bash
# create DB test
> use gt-test-db
# insert documents into DB test
> db.gtTestCollection.insert([{name:"Tom", gender:"male"},{name:"Jack", gender:"male"},{name:"Marry", gender:"female"}]);
```

#5 Connect to mongo instance 
```bash
# mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]

# from studio3T
mongodb://admin:admin@localhost:8081/gt-test-db?authSource=admin&authMechanism=SCRAM-SHA-256

# from bash inside container 
docker exec -it myMongoContainer /bin/sh/bin/mongosh "mongodb://admin:admin@localhost:27017/gt-test-db?authSource=admin&authMechanism=SCRAM-SHA-256"
```
success !

#6 Config a replica set
3_mongod 
```bash
# stop & delete old mongo members 
docker stop `docker ps -aq -f "name=myMongoContainer*"` 
docker rm `docker ps -aq -f "name=myMongoContainer*"`
# start 3 mongod members with specific replicaSet name
docker run -d --name myMongoContainer1 -p 8081:27017 mongo --replSet "myRS"
docker run -d --name myMongoContainer2 -p 8082:27017 mongo --replSet "myRS"
docker run -d --name myMongoContainer3 -p 8083:27017 mongo --replSet "myRS"
docker run -d --name myMongoContainer -p 8080:27017 mongo # this is like mongos, only for connection to replica set
# health check mongod member ip
docker exec -it myMongoContainer1 bash -c "echo myMongoContainer1; hostname -I"
docker exec -it myMongoContainer2 bash -c "echo myMongoContainer2; hostname -I"
docker exec -it myMongoContainer3 bash -c "echo myMongoContainer3; hostname -I"
# add ip&hostname to each mongod /etc/hosts, then then can talk to each other
docker exec -it myMongoContainer1 bash -c "echo '172.17.0.2 myMongoContainer1' >> /etc/hosts; echo '172.17.0.3 myMongoContainer2' >> /etc/hosts; echo '172.17.0.4 myMongoContainer3' >> /etc/hosts; exit;"
docker exec -it myMongoContainer2 bash -c "echo '172.17.0.2 myMongoContainer1' >> /etc/hosts; echo '172.17.0.3 myMongoContainer2' >> /etc/hosts; echo '172.17.0.4 myMongoContainer3' >> /etc/hosts; exit;"
docker exec -it myMongoContainer3 bash -c "echo '172.17.0.2 myMongoContainer1' >> /etc/hosts; echo '172.17.0.3 myMongoContainer2' >> /etc/hosts; echo '172.17.0.4 myMongoContainer3' >> /etc/hosts; exit;"
docker exec -it myMongoContainer bash -c "echo '172.17.0.2 myMongoContainer1' >> /etc/hosts; echo '172.17.0.3 myMongoContainer2' >> /etc/hosts; echo '172.17.0.4 myMongoContainer3' >> /etc/hosts; exit;"
# health check mongod member hosts
docker exec -it myMongoContainer1 bash -c "echo myMongoContainer1; cat /etc/hosts "
docker exec -it myMongoContainer2 bash -c "echo myMongoContainer2; cat /etc/hosts "
docker exec -it myMongoContainer3 bash -c "echo myMongoContainer3; cat /etc/hosts "
docker exec -it myMongoContainer bash -c "echo myMongoContainer; cat /etc/hosts "
# config replica set in 1 mongod member and health check RS status 
docker exec -it myMongoContainer mongosh "mongodb://myMongoContainer1:27017/admin"
> # port=27017 as communications between mongod instances are mongod direct to mongod via 27017(default in /etc/mongo.conf), not the 8081,8082,8083 published to host.
> rs.initiate({_id: "myRS", members: [{_id: 0, host: "myMongoContainer1:27017"}, {_id: 1, host: "myMongoContainer2:27017"}, {_id: 2, host: "myMongoContainer3:27017"}]}); 
> rs.conf();
> rs.status();
# mongoDB user management
> # 创建一个名为 admin，密码为 123456 的用户。
> use admin
> db.createUser({ user:'admin',pwd:'admin',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
> # 尝试使用上面创建的用户信息进行连接。
> db.auth('admin', 'admin')
# 简单插入几条数据到测试数据库
> # create DB test
> use gt-test-db
> # insert documents into DB test
> db.gtTestCollection.insert([{name:"Tom", gender:"male"},{name:"Jack", gender:"male"},{name:"Marry", gender:"female"}]);
# direct connect to mongod members
docker exec -it myMongoContainer mongosh "mongodb://admin:admin@myMongoContainer1:27017/gt-test-db?authSource=admin"
docker exec -it myMongoContainer mongosh "mongodb://admin:admin@myMongoContainer2:27017/gt-test-db?authSource=admin"
docker exec -it myMongoContainer mongosh "mongodb://admin:admin@myMongoContainer3:27017/gt-test-db?authSource=admin"
# connect to mongo replica set
# from studio3T
#mongodb://admin:admin@myMongoContainer1:27017,myMongoContainer2:27017,myMongoContainer3:27017/gt-test-db?replicaSet=myRS
#mongodb://admin:admin@172.17.0.2:27017,172.17.0.3:27017,172.17.0.4:27017/gt-test-db?replicaSet=myRS
#mongodb://admin:admin@localhost:8081,localhost:8082,localhost:8083/gt-test-db?replicaSet=myRS
# from bash inside container 
docker exec -it myMongoContainer mongosh "mongodb://myMongoContainer1:27017,myMongoContainer2:27017,myMongoContainer3:27017?replicaSet=myRS" # work, default connect to test DB
docker exec -it myMongoContainer mongosh "mongodb://myMongoContainer1:27017,myMongoContainer2:27017,myMongoContainer3:27017/gt-test-db?replicaSet=myRS" # work, connect to target DB
docker exec -it myMongoContainer mongosh "mongodb://172.17.0.2:27017,172.17.0.3:27017,172.17.0.4:27017/gt-test-db?replicaSet=myRS" # use IP to connect
```
success ! 

#7 Config a sharding cluster 
1_mongos + 1_configServer_replicaSet + 2_shard_replicaSet

config inside 1 server
```bash
# 0.stop & delete old mongo members 
docker stop `docker ps -aq -f "name=myMC*"` 
docker rm `docker ps -aq -f "name=myMC*"`

# 1.login to a vm 
docker run -d --name myMC_shardCluster -p 9000:27017 mongo
docker exec -it myMC_shardCluster bash

# 2.install vim for vm
apt-get update
apt-get install vim
apt-get install less
which vim

# 3.setup configServer replicaSet
# 3.1.prepare mongo config files
cp -pr /etc/mongodS0.conf.orig /etc/mongoConf1.conf
cp -pr /etc/mongodS0.conf.orig /etc/mongoConf2.conf
cp -pr /etc/mongodS0.conf.orig /etc/mongoConf3.conf

# 3.2.adjust configuration files and related folder
"---- mongoConf1.conf ----------------------------
storage:
  dbPath: /var/lib/mongodb/mongoConf1
systemLog:
  path: /var/log/mongodb/mongoConf1/mongod.log
net:
  port: 9001
  bindIp: 127.0.0.1
sharding:
  clusterRole: configsvr
replication:
  replSetName: myConfigServer
-------------------------------------------------"

mkdir -p /var/lib/mongodb/mongoConf1
mkdir -p /var/log/mongodb/mongoConf1

mkdir -p /var/lib/mongodb/mongoConf2
mkdir -p /var/log/mongodb/mongoConf2

mkdir -p /var/lib/mongodb/mongoConf3
mkdir -p /var/log/mongodb/mongoConf3

# 3.3.startup configServers` mongod instances
cd ~
nohup mongod --config /etc/mongoConf1.conf &
nohup mongod --config /etc/mongoConf2.conf &
nohup mongod --config /etc/mongoConf3.conf &

# 3.4.connect to 1 instance to init configServer replicaSet
mongosh --host localhost --port 9001
"
rs.initiate(
  {
    _id: "myConfigServer",
    configsvr: true,
    members: [
      { _id : 0, host : "localhost:9001" },
      { _id : 1, host : "localhost:9002" },
      { _id : 2, host : "localhost:9003" }
    ]
  }
)
"

done, success init config server replica set 

# 4.setup shardReplicaSets
# 4.1.prepare mongo config files
cp -pr /etc/mongodS0.conf.orig /etc/mongodS0N1.conf
cp -pr /etc/mongodS0.conf.orig /etc/mongodS0N2.conf
cp -pr /etc/mongodS0.conf.orig /etc/mongodS0N3.conf

# 4.2.adjust configuration files and related folder
"---- mongodS0N1.conf ----------------------------
storage:
  dbPath: /var/lib/mongodb/mongodS0N1
systemLog:
  path: /var/log/mongodb/mongodS0N1/mongod.log
net:
  port: 9011
  bindIp: 127.0.0.1
sharding:
  clusterRole: shardsvr
replication:
  replSetName: mongodS0
-------------------------------------------------"

mkdir -p /var/lib/mongodb/mongodS0N1
mkdir -p /var/log/mongodb/mongodS0N1

mkdir -p /var/lib/mongodb/mongodS0N2
mkdir -p /var/log/mongodb/mongodS0N2

mkdir -p /var/lib/mongodb/mongodS0N3
mkdir -p /var/log/mongodb/mongodS0N3

# 4.3.startup shard0` mongod instances
cd ~
nohup mongod --config /etc/mongodS0N1.conf &
nohup mongod --config /etc/mongodS0N2.conf &
nohup mongod --config /etc/mongodS0N3.conf &

# 4.4.connect to 1 instance to init shard0 replicaSet
mongosh --host localhost --port 9011
"
rs.initiate(
  {
    _id: "mongodS0",
    members: [
      { _id : 0, host : "localhost:9011" },
      { _id : 1, host : "localhost:9012" },
      { _id : 2, host : "localhost:9013" }
    ]
  }
)
"

done, success init shard0 replica set 

# 5.setup mongos
# 5.1.prepare mongo config files
cp -pr /etc/mongodS0.conf.orig /etc/mongodSN1.conf

# 5.2.adjust configuration files and related folder
"---- mongodSN1.conf ---------------------------- 
systemLog:
  path: /var/log/mongodb/mongodSN1/mongod.log
net:
  port: 9101
  bindIp: 127.0.0.1
sharding:
  configDB: myConfigServer/127.0.0.1:9001,127.0.0.1:9002,127.0.0.1:9003
-------------------------------------------------"

mkdir -p /var/log/mongodb/mongodSN1

# 5.3.startup mongos instance
cd ~
nohup mongos --config /etc/mongodSN1.conf &

# 5.4.connect to mongos to add shard0 to cluster
mongosh --host localhost --port 9101
"
sh.addShard( "mongodS0/localhost:9011,localhost:9012,localhost:9013")
"




```


config in multi servers
via command line -> failed
```bash
# stop & delete old mongo members 
docker stop `docker ps -aq -f "name=myMC*"` 
docker rm `docker ps -aq -f "name=myMC*"`

# Create the Config Server Replica Set
## start 3 mongod members with specific replicaSet name
#docker run -d --name myMC_config1 -p 9001:27017 mongo --configsvr --replSet "myConfigSvr" --bind_ip localhost,myMC_config1
#docker run -d --name myMC_config2 -p 9002:27017 mongo --configsvr --replSet "myConfigSvr" --bind_ip localhost,myMC_config2
#docker run -d --name myMC_config3 -p 9003:27017 mongo --configsvr --replSet "myConfigSvr" --bind_ip localhost,myMC_config3

docker run -d --name myMC_config1 -p 9001:27017 mongo --configsvr --replSet "myConfigSvr"
docker run -d --name myMC_config2 -p 9002:27017 mongo --configsvr --replSet "myConfigSvr"
docker run -d --name myMC_config3 -p 9003:27017 mongo --configsvr --replSet "myConfigSvr"

#docker run -d --name myMC_config1 -p 9001:27017 mongo --replSet "myConfigSvr"
#docker run -d --name myMC_config2 -p 9002:27017 mongo --replSet "myConfigSvr"
#docker run -d --name myMC_config3 -p 9003:27017 mongo --replSet "myConfigSvr"


## get hostname
host_conf1=$(docker exec myMC_config1 bash -c "hostname -I");
host_conf2=$(docker exec myMC_config2 bash -c "hostname -I");
host_conf3=$(docker exec myMC_config3 bash -c "hostname -I");
## add hostname to each member
docker exec myMC_config1 bash -c "echo -e '$host_conf1 myMC_config1\n$host_conf2 myMC_config2\n$host_conf3 myMC_config3' >> /etc/hosts"
docker exec myMC_config2 bash -c "echo -e '$host_conf1 myMC_config1\n$host_conf2 myMC_config2\n$host_conf3 myMC_config3' >> /etc/hosts"
docker exec myMC_config3 bash -c "echo -e '$host_conf1 myMC_config1\n$host_conf2 myMC_config2\n$host_conf3 myMC_config3' >> /etc/hosts"
## health check hosts
docker exec myMC_config1 bash -c "echo myMC_config1; cat /etc/hosts"
docker exec myMC_config2 bash -c "echo myMC_config2; cat /etc/hosts"
docker exec myMC_config3 bash -c "echo myMC_config3; cat /etc/hosts"
## connect to 1 configServer to config replica set
docker exec -it myMC_config1 mongosh "mongodb://myMC_config1:27017/admin"
docker exec -it myMC_config1 mongosh "mongodb://localhost:27017/admin"
docker exec -it myMC_config1 mongosh
docker exec -it myMC_config1 bash
docker exec -it myMongoContainer mongosh "mongodb://myMongoContainer1:27017/admin"

mongosh --host localhost --port 27017
mongosh --host localhost --port 9001
mongosh --host 172.17.0.2 --port 9001
mongosh --host 172.17.0.2 --port 27017

mongos --configdb myMC_config1:27017,myMC_config1:27017,myMC_config1:27017

# Create the Shard Replica Sets

# Start a mongos for the Sharded Cluster

# Connect to the Sharded Cluster

# Add Shards to the Cluster

# Shard a Collection

```
---

---
Docker tips : 
```bash
#show all container ID
docker ps -aq

# delete all container
docker rm `docker ps -aq`

# get container IP
docker exec -it myMongoContainer1 /usr/bin/hostname -I

# connect to container with bash cli
docker exec -it myMongoContainer1 /bin/bash 

# run bash cmd from container
docker exec -it myMongoContainer1 bash -c "echo myMongoContainer1; cat /etc/hosts "

```

# mongoDemo
