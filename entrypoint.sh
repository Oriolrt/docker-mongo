#!/bin/bash

# Per crear el usuari amb les UIDs i GIDs que toquen...
/root/createUser.sh

# Els bind mounts del host (/data/db, /data/configdb, /home/student/scripts)
# sobreescriuen la propietat feta en build-time, cal refer-la aquí.
chown -R student:"$(id -gn student)" /data/db /data/configdb /home/student/scripts

# Inicia el servei SSH com a root
service ssh start

# Executa mongod com a l'usuari student
exec su -s /bin/bash student -c 'mongod --dbpath /data/db  \
  --bind_ip_all \
  --logpath /data/db/mongod.log \
  --logRotate reopen \
  --logappend  \
  --wiredTigerCacheSizeGB 1 \
  --quiet'

