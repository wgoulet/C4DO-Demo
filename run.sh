#!/bin/bash

# from https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions
generate_post_data()
{
    cat <<EOF
{
  "common_name":"$1"
}
EOF
}
CONTAINER_FQDN=$1
VAULT_TOKEN=$2
VAULT_ROLE_URL=$3
VAULT_PIKCUP_URL=$4
echo $CONTAINER_FQDN
echo $VAULT_TOKEN


CERTSERIAL=`curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X POST $3 -d "$(generate_post_data $CONTAINER_FQDN)" | jq '.data.serial_number' -j | sed -e s/:/-/g`
echo $CERTSERIAL

curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X GET $4$CERTSERIAL | jq '.data.certificate_chain' -j
curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X GET $4$CERTSERIAL | jq '.data.certificate_chain' -j >> /etc/ssl/nginx.crt
curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X GET $4$CERTSERIAL | jq '.data.private_key' -j >> /etc/ssl/nginx.key
nginx -g "daemon off;"
