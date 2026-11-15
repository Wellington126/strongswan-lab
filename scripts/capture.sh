#!/usr/bin/env bash
# Captura 8 s no servidor enquanto o cliente faz ping. Uso: ./scripts/capture.sh <nome>
set -euo pipefail
cd "$(dirname "$0")/.."
NAME="${1:-captura}"
docker exec ipsec-server timeout 8 tcpdump -i eth0 -n -U -w "/captures/${NAME}.pcap" &
sleep 2
docker exec ipsec-client ping -c 5 10.99.0.10
wait || true
docker exec ipsec-server chmod 644 "/captures/${NAME}.pcap"
echo "Capturado: captures/${NAME}.pcap"
