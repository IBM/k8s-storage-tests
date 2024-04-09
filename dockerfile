FROM quay.io/operator-framework/ansible-operator:v1.34.1

LABEL name="k8s-storage-test" \
      maintainer="Nathan Brophy <nathan.brophy@ibm.com>" \
      vendor="IBM" \
      version="v1.0.0" \
      release="Version 1.0.0 containerized packaging for the K8s sotrage test ansible playbooks" \
      summary="This is a containerized version of the k8s-storage-tests ansible playbooks" \
      description="This image contains the ansible playbooks for running the storage test execution suite"

USER 0

ENV USER_UID=1001
ENV ANSIBLE_PYTHON_INTERPRETER /usr/local/bin/python
ENV PATH ${PATH}:${HOME}/bin

RUN mkdir /licenses
COPY LICENSE /licenses
COPY . ${HOME}
COPY cleanup.sh /usr/local/bin/cleanup.sh
COPY roles/* ${HOME}/roles/

RUN ln -fs ${HOME}/bin/entrypoint /usr/local/bin/entrypoint

RUN pip3 install openshift && pip3 install Jinja2 && pip3 install yasha && pip3 install argparse \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 install "oauthlib>=3.2.0" \
    && ansible-galaxy collection install operator_sdk.util \
    && ansible-galaxy collection install kubernetes.core \
    && curl -sL https://github.com/openshift/okd/releases/download/4.8.0-0.okd-2021-11-14-052418/openshift-client-linux-4.8.0-0.okd-2021-11-14-052418.tar.gz | tar xvz --directory /usr/local/bin/. \
    && chown -R ${USER_UID}:0 ${HOME} && chmod -R ug+rwx ${HOME}

USER ${USER_UID}

ENTRYPOINT ["/usr/local/bin/entrypoint"]
