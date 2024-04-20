#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
# Loading conjur appliance image
podman image ls | grep -q conjur-appliance && echo "Image conjur-appliance existed!!!" || podman load -i $UPLOAD_DIR/$conjur_appliance_file
set +x
