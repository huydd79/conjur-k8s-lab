#!/bin/sh
podman rmi $(podman images -a | grep cityapp | awk '{print $3}')
podman rmi $(podman images --filter "dangling=true" -q --no-trunc)