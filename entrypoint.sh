#!/bin/bash

# Crear usuari amb UID i GID del host
/root/createUser.sh

# Assegura que el home de student existeix i és seu
chown -R student:student /home/student
chown -R student:student /data/db
# Crear /data/configdb si no existeix
if [ ! -d /data/configdb ]; then
  mkdir -p /data/configdb
fi
chown -R student:student /data/configdb

# Inicia el servei SSH com a root
service ssh start

# Executa mongod com a l'usuari student
exec su student -c 'mongod --dbpath /data/db --bind_ip_all'
