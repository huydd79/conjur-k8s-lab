#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
conjur -d policy load -f ./policies/authn-jwt-k8s.yaml -b root

# TODO: check this command to see if can be removed:
#podman exec $node_name chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-jwt/k8s"]
podman exec -it $node_name sh -c 'grep -q "authn,authn-jwt/k8s" /opt/conjur/etc/conjur.conf || echo "CONJUR_AUTHENTICATORS=\"authn,authn-jwt/k8s\"\n">>/opt/conjur/etc/conjur.conf'
podman exec $node_name sv restart conjur
set +x
