#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x

cd build
podman build -t cityapp:php .
cd ..
podman image ls | grep cityapp
set +x