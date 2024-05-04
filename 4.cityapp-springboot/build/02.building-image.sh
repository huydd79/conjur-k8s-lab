#!/bin/bash

sudo podman build -t cityapp-conjur-springboot-plugin .
sudo podman tag cityapp-conjur-springboot-plugin cityapp-springboot
sudo podman image ls