#!/usr/bin/env bash

# Exit immediately on error or undefined variable.
set -eu


# Process command line arguments.

if [[ $# -ne 1 ]]
then
    echo >&2 "usage: install-rundeck-admin.sh rundeck_url"
    exit 2
fi
RUNDECK_URL=$1

RERUN_REPO_URL=https://bintray.com/rerun/rerun-rpm/rpm

# Software install
# ----------------
# Utilities
# Bootstrap a fedora repo to get xmlstarlet

curl -s http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -o epel-release.rpm -z epel-release.rpm
if ! rpm -q epel-release
then
    rpm -Uvh epel-release.rpm
fi
yum -y install xmlstarlet coreutils

#
# Rerun 
#

curl -# --fail -L -o /etc/yum.repos.d/rerun.repo "$RERUN_REPO_URL" || {
    echo "failed downloading rerun.repo config"
    exit 2
}

yum -y install rerun rerun-rundeck-admin


if [[ -n ${RUNDECK_URL:-} ]]
then
cat >> ~rundeck/.bashrc <<EOF
export RUNDECK_URL=$RUNDECK_URL RUNDECK_USER=admin RUNDECK_PASSWORD=admin
EOF
chown rundeck:rundeck ~rundeck/.bashrc
fi
