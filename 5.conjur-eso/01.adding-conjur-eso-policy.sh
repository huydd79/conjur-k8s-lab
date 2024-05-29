#!/bin/bash

set -x
conjur -d policy load -f ./yaml/conjur-eso-jwt-policy.yaml -b root

conjur variable set -i test/host2/host -v test2.demo.local
conjur variable set -i test/host2/user -v test2user
conjur variable set -i test/host2/pass -v SecureP@s5

set +x
