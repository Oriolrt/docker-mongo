FROM mongo  
MAINTAINER Oriol Ramos Terrades <oriol.ramos@uab.cat>

RUN apt-get update && \
	apt-get install -y apg \
  openssh-client \
	openssh-server \
  vim

COPY createUser.sh /root/createUser.sh
RUN chmod +x /root/createUser.sh
RUN /root/createUser.sh && rm /root/createUser.sh

EXPOSE 27017
EXPOSE 22

CMD service ssh start && mongod --bind_ip_all  && bash


