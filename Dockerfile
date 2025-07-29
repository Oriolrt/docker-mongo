FROM mongo:7.0  
MAINTAINER Oriol Ramos Terrades <oriol.ramos@uab.cat>

RUN apt-get update && \
  apt-get install -y apg \
  numactl \
  openssh-client \
  openssh-server \
  vim \
  sudo && \
  apt-get clean


# Copia els scripts
COPY createUser.sh /root/createUser.sh
COPY entrypoint.sh /entrypoint.sh

# Dona permisos d'execució
RUN chmod +x /root/createUser.sh /entrypoint.sh

# Crear usuari amb UID i GID del host
RUN /root/createUser.sh 

RUN test  -d /data/configdb ||   mkdir -p /data/configdb
RUN test -d /home/student/scripts ||  mkdir -p /home/student/scripts 
RUN chown -R student:mongodb /data/db
RUN chown -R student:mongodb /data/configdb


# Prepara carpetes necessàries per SSH
RUN mkdir /var/run/sshd

# Punt de muntatge per compartir dades amb l'host
RUN mkdir -p /home/student/scripts
RUN chown -R student:mongodb /home/student/scripts

EXPOSE 27017
EXPOSE 22

# Executa l'entrypoint
ENTRYPOINT ["/entrypoint.sh"]


