FROM registry.access.redhat.com/ubi9-minimal:latest as gcc-build

RUN microdnf install gcc --nodocs --noplugins --setopt=install_weak_deps=0 -y && \
    mkdir -p /tmp/lfcopy
COPY lock-file.c /tmp/lfcopy
RUN gcc -o /tmp/lfcopy/lock-file /tmp/lfcopy/lock-file.c


FROM cp.stg.icr.io/cp/cpd/ansible-operator-base:2.0.0-latest

LABEL name="k8s-storage-test" \
      maintainer="IBM" \
      vendor="IBM" \
      version="CP4D_VERSION" \
      release="Containerized packaging for the K8s sotrage test ansible playbooks" \
      summary="This is a containerized version of the k8s-storage-tests ansible playbooks" \
      description="This image contains the ansible playbooks for running the storage test execution suite"

USER 0

ARG architecture

ENV USER_UID=1001
ENV ANSIBLE_PYTHON_INTERPRETER /usr/local/bin/python
ENV PATH ${PATH}:${HOME}/bin
ENV ARCHITECTURE=${architecture}

RUN mkdir -p /licenses
COPY LICENSE /licenses

COPY bin ${HOME}/bin
COPY roles ${HOME}/roles
COPY *.yml LICENSE *.py *.sh ${HOME}
COPY cleanup.sh /usr/local/bin/cleanup.sh
COPY --from=gcc-build /tmp/lfcopy/lock-file /usr/local/bin/lock-file

###
ENV EXTRA_UID=1000321000
ENV EXTRA_GID=1000321000

# NOTE: build/run fails on Mac with rootless podman
RUN groupadd -g ${EXTRA_GID} cpuser && \
    useradd -l -u ${EXTRA_UID} -g ${EXTRA_GID} -d /home/cpuser -s /bin/sh cpuser &&\
    echo "User added."

RUN chgrp ${EXTRA_GID} -R /home/cpuser && \
  chmod g+rwx,o+r /home/cpuser

RUN umask 007 && echo "file permissions test create file " >> /home/cpuser/gidtest.txt && \
    echo "file permissions test create file " >> /home/cpuser/sgtest.txt

RUN chown ${EXTRA_UID}:${EXTRA_GID} /home/cpuser/gidtest.txt && \
    chown 3000:3000 /home/cpuser/sgtest.txt
###

RUN microdnf -y install python3-pip util-linux-core \
    && pip3 --no-cache-dir install --upgrade pip setuptools
RUN ln -fs ${HOME}/bin/entrypoint /usr/local/bin/entrypoint

RUN pip3 install openshift && pip3 install Jinja2 && pip3 install yasha && pip3 install argparse \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 install "oauthlib>=3.2.0" \
    && ansible-galaxy collection install operator_sdk.util \
    && ansible-galaxy collection install kubernetes.core \
    && curl -sL http://icpfs1.svl.ibm.com/zen/rebuild-binaries/oc/latest/${ARCHITECTURE}/go-latest/oc.tgz | tar xvz --directory /usr/local/bin/. \
    && chown -R ${USER_UID}:0 ${HOME} && chmod -R ug+rwx ${HOME}

# clean cache to save image space
RUN microdnf clean all && rm -rf /var/cache/* /var/log/dnf* /var/log/yum.* /usr/share/zoneinfo

USER ${USER_UID}

ENTRYPOINT ["/usr/local/bin/entrypoint"]
