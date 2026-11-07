#!/bin/sh
# Pearl miner entrypoint for SaladCloud (self-healing: restarts miner on exit,
# so the container keeps a continuous foreground process across reallocations).
set -u

# Debug override: any arguments replace the miner loop (e.g. SRBMiner-MULTI --help)
if [ "$#" -gt 0 ]; then exec "$@"; fi

# Required: Kryptex account identifier (e-mail used to log in at pool.kryptex.com)
KRYPTEX_USER="${KRYPTEX_USER:?set KRYPTEX_USER (your Kryptex e-mail)}"
# Worker name: prefix + container hostname suffix so every replica is unique
WORKER="${WORKER_PREFIX:-s4090}-$(hostname | tail -c 8)"
# SSL stratum (port 8048), global first, EU as backup (comma-separated, same order for wallets)
POOLS="${POOLS:-prl.kryptex.network:8048,prl-eu.kryptex.network:8048}"
WALLETS="${KRYPTEX_USER}/${WORKER},${KRYPTEX_USER}/${WORKER}"

echo "[entrypoint] worker=${WORKER} pools=${POOLS}"

while true; do
  /opt/srbminer/SRBMiner-MULTI \
    --disable-cpu \
    --algorithm pearlhash \
    --pool "${POOLS}" \
    --wallet "${WALLETS}" \
    --tls true \
    --api-enable --api-port 21550 --api-rig-name "${WORKER}"
  echo "[entrypoint] miner exited ($?), restarting in 10s"
  sleep 10
done
