#!/bin/bash

# Per crear el usuari amb les UIDs i GIDs que toquen... 
/root/createUser.sh

# Assegura que el home de student existeix i és seu
#chown -R student:student /home/student
#chown -R student:student /data/db
# Crear /data/configdb si no existeix
#if [ ! -d /data/configdb ]; then
#  mkdir -p /data/configdb
#fi
#if [ ! -d /home/student/scripts ]; then
#  mkdir -p /home/student/scripts
#fi
#chown -R student:student /data/configdb
#touch /home/student/mongod.log

# Inicia el servei SSH com a root
service ssh start

# Executa mongod com a l'usuari student
exec su -s /bin/bash mongodb -c 'mongod --dbpath /data/db  \
  --bind_ip_all \
  --logpath /data/db/mongod.log \
  --logRotate reopen \
  --logappend  \
  --wiredTigerCacheSizeGB 1 \
  --quiet'

# Executa mongod com a usuari student
# exec mongod --dbpath /data/db --bind_ip_all

echo "Servidor de MongoDB funcionant"

exec "$@"

