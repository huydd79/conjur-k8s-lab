#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
yum -y install podman jq
sudo systemctl enable podman-restart.service
sudo systemctl start podman-restart.service

set +x
