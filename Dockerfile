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

# Prepara carpetes necessàries per SSH
RUN mkdir /var/run/sshd

EXPOSE 27017
EXPOSE 22

# Punt de muntatge per compartir dades amb l'host
VOLUME /home/student

# Executa l'entrypoint
ENTRYPOINT ["/entrypoint.sh"]


