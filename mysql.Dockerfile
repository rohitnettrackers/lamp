# use debian latest
FROM debian:latest

#Set required env
ENV DEBIAN_FRONTEND "noninteractive"
ENV MYSQL_ROOT_PASSWORD tester123
ENV MYSQL_DATA /var/lib/mysql
ENV MYSQL_RUN_DIR /var/run/mysqld
ENV MYSQL_LOG_DIR /var/log/mysql
ENV MYSQL_CONF_DIR /etc/mysql/

#Update container repository and install mysql
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN apt-get update -y && apt-get install -y --no-install-recommends apt-utils locales debconf-utils
RUN apt-get install -y mariadb-server
RUN rm -rf /var/lib/apt/lists/*

#configure mysql
RUN mkdir -p $MYSQL_RUN_DIR
RUN chown mysql:mysql -R $MYSQL_RUN_DIR
RUN chown mysql:mysql -R $MYSQL_DATA
RUN chown mysql:mysql -R $MYSQL_LOG_DIR
RUN rm -rf "$MYSQL_DATA/*"
COPY ./my.cnf "$MYSQL_CONF_DIR"

VOLUME ["$MYSQL_DATA", "$MYSQL_LOG_DIR"]

COPY mysql_run.sh /run.sh
RUN chmod a+x /run.sh
CMD "./run.sh"

ENV DEBIAN_FRONTEND teletype
