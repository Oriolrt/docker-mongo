#/bin/bash
service ssh start &

chown -R student:student /data/db/

su student -c 'mongod --dbpath /data/db/ --bind_ip_all' 
