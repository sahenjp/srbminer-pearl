#!/bin/sh
# Pearl miner entrypoint (2Miners) — self-healing: restarts miner on exit,
# so the container keeps a continuous foreground process.
set -u

# Debug override: any arguments replace the miner loop (e.g. SRBMiner-MULTI --help)
if [ "$#" -gt 0 ]; then exec "$@"; fi

# Required: Pearl payout address (prl1...) — 2Miners pays PRL directly to it
PRL_ADDRESS="${PRL_ADDRESS:?set PRL_ADDRESS (your prl1... Pearl address)}"
# Worker name: prefix + container hostname suffix so every replica is unique
WORKER="${WORKER_PREFIX:-rental}-$(hostname | tail -c 8)"
# 2Miners Pearl stratum (plain stratum on port 1818); wallet = ADDRESS.WORKER
POOLS="${POOLS:-prl.2miners.com:1818}"
WALLET="${PRL_ADDRESS}.${WORKER}"

echo "[entrypoint] worker=${WORKER} pools=${POOLS}"

while true; do
  /opt/srbminer/SRBMiner-MULTI \
    --disable-cpu \
    --algorithm pearlhash \
    --pool "${POOLS}" \
    --wallet "${WALLET}" \
    --api-enable --api-port 21550 --api-rig-name "${WORKER}"
  echo "[entrypoint] miner exited ($?), restarting in 10s"
  sleep 10
done
