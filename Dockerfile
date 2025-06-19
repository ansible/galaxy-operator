FROM quay.io/operator-framework/ansible-operator:v1.36.1

ARG DEFAULT_GALAXY_VERSION
ARG DEFAULT_GALAXY_UI_VERSION
ARG OPERATOR_VERSION
ENV DEFAULT_GALAXY_VERSION=${DEFAULT_GALAXY_VERSION}
ENV DEFAULT_GALAXY_UI_VERSION=${DEFAULT_GALAXY_UI_VERSION}
ENV OPERATOR_VERSION=${OPERATOR_VERSION}

ENV ANSIBLE_FORCE_COLOR=true
ENV ANSIBLE_SHOW_TASK_PATH_ON_FAILURE=true

USER root
RUN dnf update --security --bugfix -y

USER ${USER_UID}

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install --force -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/

ENTRYPOINT ["/tini", "--", "/usr/local/bin/ansible-operator", "run", \
    "--watches-file=./watches.yaml", \
    "--reconcile-period=0s", \
    "--ansible-log-events=Tasks" \
]
