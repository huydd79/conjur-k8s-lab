#!/bin/sh
#curl -O https://raw.githubusercontent.com/joetanx/conjur-k8s/main/Dockerfile
#curl -O https://raw.githubusercontent.com/joetanx/conjur-k8s/main/index.php
podman build -t cityapp:php .
#rm -rf Dockerfile index.php
