#!/usr/bin/env bash
# Gera duas capturas: sem tunel (ICMP em claro) e com tunel (ESP cifrado).
set -euo pipefail
cd "$(dirname "$0")/.."
docker exec ipsec-client swanctl --terminate --ike lab || true
./scripts/capture.sh sem-tunel
docker exec ipsec-client swanctl --initiate --child lab-tunnel
./scripts/capture.sh com-tunel
