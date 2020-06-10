# Pull base image.
FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir /fiona /data
VOLUME /data

RUN \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y --no-install-recommends apt-utils \
    unzip build-essential vim \
    libc6:i386 libncurses5:i386 libstdc++6:i386 \
    software-properties-common

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client libmysqlclient-dev \
 && rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /fiona
ENV FIONA_VERSION 7.0.1

# Define working directory.
WORKDIR /fiona

ADD /Infopark-CMS-Fiona-7.0.1-Linux.zip .
RUN unzip Infopark-CMS-Fiona-7.0.1-Linux.zip && rm -f Infopark-CMS-Fiona-7.0.1-Linux.zip

ADD /infopark-internal-restricted-license-fiona7.xml .
RUN ln -s infopark-internal-restricted-license-fiona7.xml license.xml
ADD /setup.sh /Infopark-CMS-Fiona-7.0.1-Linux/
ADD /install_trifork.sh .
RUN chmod +x /Infopark-CMS-Fiona-7.0.1-Linux/setup.sh
RUN /Infopark-CMS-Fiona-7.0.1-Linux/setup.sh
RUN rm -rf /Infopark-CMS-Fiona-7.0.1-Linux \
      infopark-internal-restricted-license-fiona7.xml \
      install_trifork.sh \
      license.xml \
      npsinstall.log

ADD /wait-for-it.sh .
RUN chmod +x wait-for-it.sh

ADD /start.sh .
RUN chmod +x start.sh

ADD /cms/bin/CM.sh /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM
RUN chmod +x /fiona/CMS-Fiona-7.0.1/instance/default/bin/CM
ADD /cms/config/*  /fiona/CMS-Fiona-7.0.1/instance/default/config/
COPY /cms/script/cm  /fiona/CMS-Fiona-7.0.1/instance/default/script/cm

# Define default command.
CMD ["bash"]
