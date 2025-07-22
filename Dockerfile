FROM mongo:7.0  
MAINTAINER Oriol Ramos Terrades <oriol.ramos@uab.cat>

RUN apt-get update && \
	apt-get install -y apg \
  numactl \
  openssh-client \
	openssh-server \
  vim
ADD entrypoint.sh /entrypoint.sh

COPY createUser.sh /root/createUser.sh
RUN chmod +x /root/createUser.sh
RUN /root/createUser.sh && rm /root/createUser.sh

EXPOSE 27017
EXPOSE 22

VOLUME /home/student

ENTRYPOINT ./entrypoint.sh -D && bash

