#!/bin/bash
# Prepara a configuracao do strongSwan conforme o papel (server|client)
# e o modo de autenticacao (psk|cert), e inicia o daemon charon em primeiro plano.
set -euo pipefail

ROLE="${ROLE:?defina ROLE=server ou ROLE=client}"
AUTH_MODE="${AUTH_MODE:-psk}"
CONF="/conf/${ROLE}-${AUTH_MODE}.conf"

[ -f "$CONF" ] || { echo "[lab] ERRO: $CONF nao existe (ROLE/AUTH_MODE invalidos)"; exit 1; }
echo "[lab] papel=${ROLE} autenticacao=${AUTH_MODE}"

install -D -m 600 "$CONF" /etc/swanctl/swanctl.conf

if [ "$AUTH_MODE" = "cert" ]; then
    for f in ca.crt "${ROLE}.crt" "${ROLE}.key"; do
        [ -f "/certs/$f" ] || { echo "[lab] ERRO: /certs/$f ausente. Rode ./gen-certs.sh antes."; exit 1; }
    done
    install -D -m 644 /certs/ca.crt        /etc/swanctl/x509ca/ca.crt
    install -D -m 644 "/certs/${ROLE}.crt" "/etc/swanctl/x509/${ROLE}.crt"
    install -D -m 600 "/certs/${ROLE}.key" "/etc/swanctl/private/${ROLE}.key"
fi

# Em segundo plano: espera o socket VICI do charon e carrega conexoes/credenciais
(
    for _ in $(seq 1 30); do
        [ -S /var/run/charon.vici ] && break
        sleep 1
    done
    swanctl --load-all
) &

# charon como PID 1 (recebe SIGTERM do "docker stop")
exec /usr/lib/ipsec/charon
