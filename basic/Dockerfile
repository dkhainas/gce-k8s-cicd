FROM jenkins/inbound-agent:latest-jdk21
USER root

RUN apt -y update && \
    apt -y install unzip python3 apt-transport-https ca-certificates gnupg curl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ARG TERRAFORM_VERSION=1.9.6
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && \
    apt-get install google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin -y
