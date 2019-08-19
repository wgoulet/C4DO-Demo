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

echo $1
echo $2

CERTSERIAL=`curl -k -H "X-Vault-Token: $2" -X POST https://vcloudvault.centralus.cloudapp.azure.com:8200/v1/venafi-pki/issue/cloud-backend -d "$(generate_post_data $1)" | jq '.data.serial_number' -j | sed -e s/:/-/g`
echo $CERTSERIAL

curl -k -H "X-Vault-Token: $2" -X GET https://vcloudvault.centralus.cloudapp.azure.com:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.certificate_chain' -j 
curl -k -H "X-Vault-Token: $2" -X GET https://vcloudvault.centralus.cloudapp.azure.com:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.certificate_chain' -j >> /etc/ssl/nginx.crt
curl -k -H "X-Vault-Token: $2" -X GET https://vcloudvault.centralus.cloudapp.azure.com:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.private_key' -j >> /etc/ssl/nginx.key
nginx -g "daemon off;"

