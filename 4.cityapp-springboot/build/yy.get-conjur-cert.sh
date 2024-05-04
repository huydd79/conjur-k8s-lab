#!/bin/sh
openssl s_client -showcerts -servername conjur-master.demo.local \
    -connect conjur-master.demo.local:443 < /dev/null 2> /dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > conjur.pem
