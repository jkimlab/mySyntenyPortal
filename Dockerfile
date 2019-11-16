FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
#COPY ./public-html/ /usr/local/apache2/htdocs/
#RUN ufw reset
RUN apt-get update -y
RUN apt-get install -y perl python wget bzip2 git openssh-server apache2
RUN apt-get install -y php php-common gcc
RUN apt-get install -y imagemagick
RUN apt-get install -y php-imagick
RUN apt-get install -y zlib1g-dev libpng-dev
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
EXPOSE 80
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
ADD . /code/
WORKDIR /code
RUN service apache2 start
RUN apt-get install -y make
RUN apt-get install -y sudo g++ automake build-essential
#ENTRYPOINT ["/bin/bash"]
