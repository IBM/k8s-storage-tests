FROM ubuntu

LABEL name="k8s-storage-test" \
      maintainer="Nathan Brophy <nathan.brophy@ibm.com>" \
      vendor="IBM" \
      version="v1.0.0" \
      release="<Release Information>" \
      summary="This is a containerized version of the k8s-storage-tests ansible playbooks" \
      description="This image contains the ansible playbooks for running the storage test execution suite"

USER 0
ENV USER_UID=1001
ENV ANSIBLE_PYTHON_INTERPRETER=/usr/local/bin/python

RUN useradd -l -u ${USER_UID} -g 0 -d ${HOME} -s /bin/sh ansible-runner \
    && echo "ansible-runner ALL=(ALL)   NOPASSWD: /bin/chmod, /bin/chown" >> /etc/sudoers 

RUN mkdir /licenses
COPY LICENSE /licenses

RUN apt-get update && \
    apt-get install -y python-is-python3 && \
    apt-get install -y pip && \
    apt-get install -y curl && \
    apt-get install -y vim && \
    pip install ansible==2.10.5 && \
    pip install openshift && \
    ansible-galaxy collection install operator_sdk.util && \
    ansible-galaxy collection install community.kubernetes &&  \
    curl -sSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6/linux/oc.tar.gz >${HOME}/oc.tar.gz && \
    tar -xvf ${HOME}/oc.tar.gz && \
    chmod +x oc && \
    cp oc /usr/local/bin

COPY . /
COPY cleanup.sh /usr/local/bin/cleanup.sh
COPY roles/* /roles/

RUN true \
    && mkdir -p /.ansible \
    && chgrp -v 0 -R  /.ansible \
    && chmod -vR g=u /.ansible /etc/passwd \
    && true

RUN  chown -R ${USER_UID}:0 ${HOME} && chmod -R ug+rwx ${HOME}
USER ${USER_UID}

CMD ["sleep", "inf"]
