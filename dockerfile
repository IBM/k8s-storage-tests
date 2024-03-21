FROM registry.access.redhat.com/ubi8/ubi-minimal
FROM quay.io/operator-framework/ansible-operator:v1.17.0

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

RUN mkdir /licenses
COPY LICENSE /licenses

COPY bin ${HOME}/bin
COPY roles ${HOME}/roles
COPY *.yml LICENSE *.py *.sh ${HOME}
COPY cleanup.sh /usr/local/bin/cleanup.sh

RUN ln -fs ${HOME}/bin/entrypoint /usr/local/bin/entrypoint

RUN pip3 install openshift && pip3 install Jinja2 && pip3 install yasha && pip3 install argparse \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 install "oauthlib>=3.2.0" \
    && ansible-galaxy collection install operator_sdk.util \
    && ansible-galaxy collection install kubernetes.core \
    && curl -sL http://icpfs1.svl.ibm.com/zen/rebuild-binaries/oc/latest/${ARCHITECTURE}/go-latest/oc.tgz | tar xvz --directory /usr/local/bin/. \
    && chown -R ${USER_UID}:0 ${HOME} && chmod -R ug+rwx ${HOME}

USER ${USER_UID}

ENTRYPOINT ["/usr/local/bin/entrypoint"]
