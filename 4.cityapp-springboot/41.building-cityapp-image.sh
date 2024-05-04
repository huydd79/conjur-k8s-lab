#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x

#Downloading necessary packages for app building
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

cd build
sudo bash -c "./mvnw clean package"
sudo podman build -t cityapp-springboot .
cd ..
sudo podman image ls | grep cityapp-springboot

set +x