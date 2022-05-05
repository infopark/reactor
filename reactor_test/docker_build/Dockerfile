# Pull base image.
FROM ubuntu:bionic

RUN mkdir /fiona /data
VOLUME /data

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN \
  dpkg --add-architecture i386 && \
  apt-get update && apt-get install -y software-properties-common gnupg && \
  # set mariadb-version
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
  add-apt-repository --remove 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu bionic main' && \
  add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu bionic main' && \
  # done setting mariadb-version
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils \
    unzip build-essential\
    libc6:i386 libncurses5:i386 libstdc++6:i386 \
    software-properties-common mariadb-client libmysqlclient-dev libmariadb3 \
    && rm -rf ${MYSQL_DATA_DIR} \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /fiona
ENV FIONA_VERSION 7.0.2

# Define working directory.
WORKDIR /fiona

COPY /Infopark-CMS-Fiona-${FIONA_VERSION}-Linux Infopark-CMS-Fiona-${FIONA_VERSION}-Linux
COPY /infopark-internal-restricted-license-fiona7.xml .
RUN ln -s infopark-internal-restricted-license-fiona7.xml license.xml
COPY /setup.sh /Infopark-CMS-Fiona-${FIONA_VERSION}-Linux/
COPY /install_trifork.sh .
RUN chmod +x /Infopark-CMS-Fiona-${FIONA_VERSION}-Linux/setup.sh
RUN /Infopark-CMS-Fiona-${FIONA_VERSION}-Linux/setup.sh
RUN rm -rf Infopark-CMS-Fiona-${FIONA_VERSION}-Linux \
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

COPY /cms/bin/CM.sh /fiona/CMS-Fiona-${FIONA_VERSION}/instance/default/bin/CM
RUN chmod +x /fiona/CMS-Fiona-${FIONA_VERSION}/instance/default/bin/CM
COPY /cms/config/*  /fiona/CMS-Fiona-${FIONA_VERSION}/instance/default/config/
COPY /cms/script/cm  /fiona/CMS-Fiona-${FIONA_VERSION}/instance/default/script/cm

COPY /my.cnf /etc/mysql/conf.d/mysql.cnf

# Define default command.
CMD ["bash"]
