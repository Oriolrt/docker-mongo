FROM mongo  
MAINTAINER Oriol Ramos Terrades <oriol.ramos@uab.cat>

RUN apt-get update && \
	apt-get install -y openssh-client \
	openssh-server

COPY createUser.sh /root/createUser.sh
RUN chmod +x /root/createUser.sh
RUN /root/createUser.sh
RUN rm /root/createUser.sh

EXPOSE 27017

ENTRYPOINT service ssh start && bash


