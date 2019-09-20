#!/bin/bash
# Usage: source attach.sh [remote_host]
# Defaults to local docker if no remote host is provided
# Remote host should be configured in ~/.ssh/config
# If you change from local to remote, the remote container will continue running (and vice-versa)

remote_host=; [ -z "$1" ] || remote_host=$1

# Execute in parent dir
#pushed=0; [ $(basename $PWD) = $(dirname $0) ] && pushd .. > /dev/null && pushed=1

attach_container () {
    echo 'Attaching to container...'
    docker-compose exec ml-workspace /bin/bash
}

start_container () {
    echo 'Rebuilding image and starting container...'
    docker-compose down
    docker-compose up --build --detach
    attach_container
}

mkdir -p $(pwd)/.docker
ssh_pidfile=$(pwd)/.docker/ssh.pid
local_sock=$(pwd)/.docker/docker.sock

tunnel_remote () {
    # docker-compose doesn't support ~/.ssh/config, so we tunnel to the socket ourselves
    # kill the socket-forwarding process if active
    [ -f "$ssh_pidfile" ] && kill -9 $(cat $ssh_pidfile) && rm $ssh_pidfile
    # remove local socket file if exists
    [ -S "$local_sock" ] && rm $local_sock
    
    # start docker daemon on remote host
    ssh $remote_host 'sudo usermod -aG docker $USER && sudo dockerd &'
    # forward the docker daemon's unix socket and point local to it
    ssh -nNT -L $local_sock:/var/run/docker.sock $remote_host &
    echo $! > $ssh_pidfile
    export DOCKER_HOST=unix://$local_sock
}

if ! [ -z "$remote_host" ]; then
    # Check if current running process is connected to the same host
    last_host=; [ -f "$ssh_pidfile" ] && last_host=$(ps -p $(cat $ssh_pidfile) -o command= | awk '{print $NF}')
    if [ "$remote_host" = "$last_host" ]; then
        # try to attach with current connection
        export DOCKER_HOST=unix://$local_sock
        attach_container || start_container || (tunnel_remote && start_container)
    else
        echo "Connecting to $remote_host..."
        tunnel_remote && (attach_container || start_container)
    fi
else
    # connect locally
    unset DOCKER_HOST
    attach_container || start_container
fi

#[ $pushed = 1 ] && popd > /dev/null