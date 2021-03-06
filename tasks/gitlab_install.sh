#!/bin/sh

# start by copying the commands from https://about.gitlab.com/install/#centos-7

# 1. Install and configure the necessary dependencies
yum install -y curl policycoreutils-python openssh-server
systemctl enable sshd
systemctl start sshd
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld

# 2. Add the GitLab package repository and install the package
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

EXTERNAL_URL="https://${PT_host}" GITLAB_ROOT_PASSWORD=$PT_password yum install -y gitlab-ee

# Disable exit on non 0
set +e

# added to ensure /var/opt/gitlab/.ssh gets correct security context
# I've found this likes to fail due to letsencrypt if you throw it a bogus
# fqdn. well be lazy for now and ignore any potential errors
gitlab-ctl reconfigure

# Enable exit on non 0
set -e
