FROM ubuntu:latest

RUN apt-get update

RUN apt-get upgrade

RUN apt-get install -y --no-install-recommends subversion

RUN apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev

WORKDIR /usr/src

RUN wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz

RUN tar xvf asterisk-20-current.tar.gz

WORKDIR /home/asterisk-20.0.0/

RUN ./contrib/scripts/get_mp3_source.sh

WORKDIR /home/asterisk-20.0.0/

RUN DEBIAN_FRONTEND=noninteractive contrib/scripts/install_prereq install -y --no-install-recommends

RUN ./configure

RUN menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts

RUN make

RUN make install

RUN make samples

RUN make config

RUN ldconfig

RUN groupadd asterisk

RUN useradd -r -d /var/lib/asterisk -g asterisk asterisk

RUN usermod -aG audio,dialout asterisk

RUN chown -R asterisk.asterisk /etc/asterisk

RUN chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk

RUN chown -R asterisk.asterisk /usr/lib/asterisk

RUN chmod -R 750 /var/{lib,log,run,spool}/asterisk /usr/lib/asterisk /etc/asterisk

RUN find /etc/default/asterisk -type f -exec sed -i 's/AST_USER="asterisk"/AST_USER="asterisk"/g' {} \;

RUN find /etc/default/asterisk -type f -exec sed -i 's/AST_GROUP="asterisk"/AST_GROUP="asterisk"/g' {} \;

RUN find /etc/asterisk/asterisk.conf -type f -exec sed -i 's/;runuser = asterisk/runuser = asterisk/g' {} \;

RUN find /etc/asterisk/asterisk.conf -type f -exec sed -i 's/;rungroup = asterisk/rungroup = asterisk/g' {} \;

RUN systemctl restart asterisk

RUN systemctl enable asterisk

WORKDIR /etc/asterisk

RUN cp pjsip.conf pjsip.conf.orig

RUN echo "[general]" > pjsip.conf
RUN echo "allowoverlap = no" >> pjsip.conf
RUN echo "" >> pjsip.conf
RUN echo "[transport-udp]" >> pjsip.conf
RUN echo "type = transport" >> pjsip.conf
RUN echo "protocol = udp" >> pjsip.conf
RUN echo "bind = 0.0.0.0" >> pjsip.conf
RUN echo "" >> pjsip.conf

RUN cp extensions.conf extensions.conf.orig

RUN echo "[phones]" > extensions.conf
RUN echo "" > extensions.conf

RUN systemctl restart asterisk
