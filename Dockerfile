FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install -y perl python wget bzip2 git openssh-server apache2 php php-common gcc imagemagick php-imagick php-imagick zlib1g-dev libpng-dev make sudo g++ automake build-essential
RUN apt-get install -y pkg-config libgd-dev
RUN wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
RUN dpkg -i http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN cpan Test::Regexp App::cpanminus Sort::Key::Natural Data::PowerSet JSON Clone Config::General
RUN cpan Font::TTF::Font GD GD::Polyline List::MoreUtils Math::Bezier Math::Round Math::VecStat Parallel::ForkManager
RUN cpan Params::Validate Readonly Regexp::Common SVG Set::IntSpan Statistics::Basic Text::Format
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
EXPOSE 80
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
ADD . /code/
WORKDIR /code
#ENTRYPOINT ["/bin/bash"]
