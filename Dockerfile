FROM debian:12-slim

# strongSwan (daemon charon + swanctl + pki) e ferramentas de teste/captura
RUN apt-get update && apt-get install -y --no-install-recommends \
        strongswan-charon \
        strongswan-swanctl \
        strongswan-pki \
        libstrongswan-standard-plugins \
        iproute2 iputils-ping tcpdump ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Logs do charon na saida padrao (visiveis em "docker logs")
COPY conf/logging.conf /etc/strongswan.d/zz-lab-logging.conf

# Configuracoes (escolhidas em tempo de execucao por ROLE e AUTH_MODE)
COPY conf/ /conf/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY gen-certs.sh  /usr/local/bin/gen-certs.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/gen-certs.sh

# IKE (500/udp) e NAT-T (4500/udp); ESP e protocolo IP 50 (nao tem porta)
EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
