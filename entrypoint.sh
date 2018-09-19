#/bin/bash
service ssh start &

chown -R student:student /u02/mongo/db/

su student -c 'mongod --dbpath /u02/mongo/db/ --bind_ip_all' 
