FROM registry.access.redhat.com/ubi8/ubi-minimal
FROM quay.io/operator-framework/ansible-operator:v1.17.0

LABEL name="k8s-storage-test" \
      maintainer="Nathan Brophy <nathan.brophy@ibm.com>" \
      vendor="IBM" \
      version="v1.0.0" \
      release="<Release Information>" \
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

RUN python3 -m pip install --upgrade pip;  pip3 uninstall -y ansible \
    && rm -rf /usr/local/lib/python3.8/site-packages/ansible* \
    && rm -f /usr/local/bin/ansible* \
    && pip3 install ansible-base~=2.10  \
    && pip3 install openshift && pip3 install Jinja2 && pip3 install yasha && pip3 install argparse \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && pip3 install "oauthlib>=3.2.0" \
    && ansible-galaxy collection install operator_sdk.util \
    && ansible-galaxy collection install community.kubernetes  \
    && curl -sSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6/linux/oc.tar.gz >${HOME}/oc.tar.gz \
    && tar -xvf ${HOME}/oc.tar.gz \
    && chmod +x oc \
    && cp oc /usr/local/bin


RUN chown -R ${USER_UID}:0 ${HOME} && chmod -R ug+rwx ${HOME}

USER ${USER_UID}

ENTRYPOINT ["/usr/local/bin/entrypoint"]
