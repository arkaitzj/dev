#!/bin/bash

function main() {
    echo "Booting for $devuser..."
    USER_UID=$(id -u $devuser)
    WORKDIR_UID=$(stat -c "%u" /workdir)


    if [ "${USER_UID}" != "${WORKDIR_UID}" ]; then
        echo "Adopting /workdir uid[${WORKDIR_UID}] for $devuser"
        sed -E -i "s/^$devuser:x:[0-9]+/$devuser:x:${WORKDIR_UID}/" /etc/passwd
        echo "Chowning back user home"
        chown -R $devuser.$devuser /home/$devuser
    else
        echo "/workdir has the same uid as $devuser, probably not bind-mounted"
    fi

    if [ -f /var/run/docker.sock ]; then
        DOCKER_GID=$(stat -c "%g" /var/run/docker.sock)
        echo "Adopting docker socket gid[${DOCKER_GID}] for docker group"
        sed -E -i "s/^docker:x:[0-9]+/docker:x:${DOCKER_GID}/" /etc/group
    else
        echo "No docker socket found mounted, not touching docker group.."
    fi





    if [ -n "$*" ]; then
        su -l $devuser -c "$*"
    else
        su - $devuser
    fi
}

main "$@"
