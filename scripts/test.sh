#!/usr/bin/env bash
# Verifica o tunel: SAs do IKEv2, ping e SAs ESP no kernel.
set -euo pipefail
echo "=== SAs (swanctl) no cliente ===";      docker exec ipsec-client swanctl --list-sas
echo "=== Ping cliente -> servidor ===";       docker exec ipsec-client ping -c 4 10.99.0.10
echo "=== SAs ESP no kernel (servidor) ===";   docker exec ipsec-server ip xfrm state
echo "=== Politicas xfrm (servidor) ===";      docker exec ipsec-server ip xfrm policy
