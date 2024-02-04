#!/bin/sh

CGROUP_MOUNTPOINT="/sys/fs/cgroup"
CGROUP_CONTROLLERS="cgroup.controllers"
SYSTEM_CGROUP="system.slice"

# This function prints an error and exits the script.
error() {
    messagway="$1"
    echo "--> ${messagway}"
    exit 1
}

# This function logs the controllers of a cgroup.
# The first argument is the name of the cgroup. If empty, uses root cgroup.
log_cgroup_controllers() {
    cgroup="$1"
    for ctl in $(cat ${CGROUP_MOUNTPOINT}/${cgroup}/${CGROUP_CONTROLLERS}) ; do
        echo "---> ${ctl}"
    done
}

# This function creates the system.slice cgroup.
create_SYSTEM_CGROUP() {
    cgroup="$SYSTEM_CGROUP"

    # Attempt to create the cgroup.
    if ! mkdir "${CGROUP_MOUNTPOINT}/${cgroup}" ; then
        error "Could not create cgroup ${cgroup}"
    fi
}

echo "=> Configuring environment for Slurm daemon..."

echo "--> Global controll group controllers:"
log_cgroup_controllers

echo "--> Creating $SYSTEM_CGROUP cgroup"
create_SYSTEM_CGROUP
echo "--> $SYSTEM_CGROUP"
log_cgroup_controllers "$SYSTEM_CGROUP"

echo "=> Starting Slurm daemon..."
/usr/sbin/slurmd -D -Z --conf="Feature=k8s Gres=gpu:0,cards:0"
