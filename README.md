
# MongoDB
MongoDB server from the official docker image. This container adds an additional layer where a ssh server is enabled and an user *student* with password *student* is created.

Below, the commands used to run this image. Please, see the official [site](https://store.docker.com/images/mongo) for all possible ways to run this image. 
 

## Quick Start

Run with 27017 port opened:
```
docker run -dti -p 55117:27017 --name mongo-1 oriolrt/mongo
```

Run this, if you want the database to be connected remotely:
```
docker run -dti -p 55117:27017 -p 55122:22  --name mongo-1 oriolrt/mongo
```

And run this if you want to mount a volume with proper privileges:
```
mkdir -p $HOME/docker_volumes/mongo/scripts;
mkdir -p $HOME/docker_volumes/mongo/data;
mkdir -p $HOME/docker_volumes/mongo/configdb;
docker run -dti \
	-e HOST_UID=$(id -u $USER) \
	-e HOST_GID=$(id -g $USER) \   
	-p 55117:27017 \
	-p 55122:22 \
	-v $HOME/docker_volumes/mongo/scripts:/home/student/scripts \
	-v $HOME/docker_volumes/mongo/data:/data/db \
	-v $HOME/docker_volumes/mongo/configdb:/data/configdb \
	--name mongo --hostname mongo \
oriolrt/mongo
```

## Remote connection

Write on a terminal on a host terminal the following command:
```
ssh -p 55122 student@localhost
```

Replace *localhost* by the IP or a hostname for a remote connection. Be sure that the specified port is opened and the IP reachable.







