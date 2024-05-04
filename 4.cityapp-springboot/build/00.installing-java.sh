#!/bin/bash

sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf upgrade -y
sudo dnf install -y java-17-openjdk java-17-openjdk-devel podman-compose