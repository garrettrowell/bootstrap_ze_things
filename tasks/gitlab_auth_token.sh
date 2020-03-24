#!/bin/sh

# Puppet Task Name: gitlab_auth_token
#

# request the auth token for user=root with password=puppetlabs from the target host
curl -d 'grant_type=password&username=root&password=puppetlabs' -k --request POST https://$(hostname)/oauth/token
