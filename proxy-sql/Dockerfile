FROM ubuntu:16.04

ENV VERSION 2.0.1

RUN apt-get update && \
    apt-get install -y wget mysql-client inotify-tools procps && \
    wget https://github.com/sysown/proxysql/releases/download/v${VERSION}/proxysql_${VERSION}-ubuntu16_amd64.deb -O /opt/proxysql_${VERSION}-ubuntu16_amd64.deb && \
    dpkg -i /opt/proxysql_${VERSION}-ubuntu16_amd64.deb && \
    rm -f /opt/proxysql_${VERSION}-ubuntu16_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 6032 6033 6080
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
