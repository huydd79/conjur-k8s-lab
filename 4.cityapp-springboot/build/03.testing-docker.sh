#!/bin/bash

set -x

CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.demo.local:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

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
        --env CONJUR_ACCOUNT=DEMO \
        --env CONJUR_APPLIANCE_URL=https://conjur-master.demo.local \
        --env CONJUR_AUTHN_LOGIN=testuser01@test \
        --env CONJUR_AUTHN_API_KEY=<using_conjur_host_rotate-api-key_to_generate_api_key> \
        --env "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}" \
        --env DB_HOST=172.16.100.15 \
        --env DB_USER=null \
        --env DB_PASS=null \
        --env DB_PORT=3306 \
        --env DB_NAME=world \
        --env CONJUR_MAPPING_DB_HOST='test/host1/host' \
        --env CONJUR_MAPPING_DB_USER='test/host1/user' \
        --env CONJUR_MAPPING_DB_PASS='test/host1/pass' \
        cityapp-conjur-springboot-plugin

sudo podman logs -f cityapp

set +x