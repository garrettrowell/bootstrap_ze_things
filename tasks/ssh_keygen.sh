#!/bin/sh

# Puppet Task Name: ssh_keygen
#

ssh-keygen -t rsa -b 4096 -N "${PT_password}" -f $PT_keyfile -C "${PT_comment}" 2>&1 > /dev/null

pubkey=$(cat ${PT_keyfile})

echo "{\"result\":{"public_key":\"${pubkey}\"}}"
