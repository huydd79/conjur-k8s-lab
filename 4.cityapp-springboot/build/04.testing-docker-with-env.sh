#!/bin/bash

set -x

sudo podman ps -a | grep cityapp
    if [[ $? -eq 0 ]]; then
        echo "Deleting node cityapp..."
        sudo podman stop cityapp
        sudo podman container rm $(sudo podman ps -a | grep cityapp | awk '{print $1}')
    fi

sudo podman run \
        --name cityapp \
        --detach -p 8080:8080 \
        --restart=unless-stopped \
        --env DB_HOST=172.16.100.15 \
        --env DB_USER=cityapp \
        --env DB_PASS=Cyberark1 \
        --env DB_PORT=3306 \
        --env DB_NAME=world \
        --env CONJUR_MAPPING_DB_HOST= \
        --env CONJUR_MAPPING_DB_USER= \
        --env CONJUR_MAPPING_DB_PASS= \
        cityapp-conjur-springboot-plugin

sudo podman logs -f cityapp

set +x