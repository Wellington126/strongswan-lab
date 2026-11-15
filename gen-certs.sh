#!/bin/bash
# Gera a CA e os certificados do servidor e do cliente em /certs.
# Uso (no host):  docker compose --profile tools run --rm certgen
set -euo pipefail
cd /certs

echo "[pki] gerando CA..."
pki --gen --type rsa --size 3072 --outform pem > ca.key
pki --self --ca --lifetime 3650 --in ca.key \
    --dn "C=BR, O=IFPB, CN=IFPB Lab CA" --outform pem > ca.crt

gen() {   # gen <nome> <ip> <flag>
    echo "[pki] gerando certificado de $1..."
    pki --gen --type rsa --size 3072 --outform pem > "$1.key"
    pki --req --type priv --in "$1.key" \
        --dn "C=BR, O=IFPB, CN=$1.lab" --san "$1.lab" --san "$2" --outform pem \
      | pki --issue --type pkcs10 --cacert ca.crt --cakey ca.key --flag "$3" \
            --lifetime 1825 --outform pem > "$1.crt"
}
gen server 10.99.0.10 serverAuth
gen client 10.99.0.20 clientAuth

chmod 644 ca.crt server.crt client.crt
chmod 600 ca.key server.key client.key
echo "[pki] pronto:"; ls -l /certs/
