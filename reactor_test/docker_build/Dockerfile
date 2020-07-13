# Pull base image.
FROM ubuntu:trusty

RUN mkdir /fiona /data
VOLUME /data

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN \
  dpkg --add-architecture i386 && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils \
    unzip build-essential\
    libc6:i386 libncurses5:i386 libstdc++6:i386 \
    software-properties-common mysql-client libmysqlclient-dev \
    && rm -rf ${MYSQL_DATA_DIR} \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /fiona
ENV FIONA_VERSION 7.0.1

# Define working directory.
WORKDIR /fiona

COPY /Infopark-CMS-Fiona-7.0.1-Linux Infopark-CMS-Fiona-7.0.1-Linux
COPY /infopark-internal-restricted-license-fiona7.xml .
RUN ln -s infopark-internal-restricted-license-fiona7.xml license.xml
COPY /setup.sh /Infopark-CMS-Fiona-7.0.1-Linux/
COPY /install_trifork.sh .
RUN chmod +x /Infopark-CMS-Fiona-7.0.1-Linux/setup.sh
RUN /Infopark-CMS-Fiona-7.0.1-Linux/setup.sh
RUN rm -rf Infopark-CMS-Fiona-7.0.1-Linux \
      infopark-internal-restricted-license-fiona7.xml \
      install_trifork.sh \
      license.xml \
      npsinstall.log

COPY /wait-for-it.sh .
RUN chmod +x wait-for-it.sh

COPY /start.sh .
RUN chmod +x start.sh

COPY /healthcheck.sh .
RUN chmod +x healthcheck.sh

COPY /cms/bin/CM.sh /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM
RUN chmod +x /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM
COPY /cms/config/*  /fiona/CMS-Fiona-7.0.1/instance/default/config/
COPY /cms/script/cm  /fiona/CMS-Fiona-7.0.1/instance/default/script/cm

COPY /my.cnf /etc/mysql/conf.d/mysql.cnf

# Define default command.
CMD ["bash"]
