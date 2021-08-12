FROM centos:latest
LABEL maintainer="JCL <jelopez@redhat.com>"

RUN yum -y update && \
    yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm && \
    yum install -y git make gcc unzip wget sysbench python3

RUN mkdir /tmp/data

WORKDIR /tmp/data

COPY ./sysbench.py /tmp/

CMD ["/bin/bash","-c","sleep 3600"]