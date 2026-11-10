#!/bin/sh
# Pearl miner entrypoint (f2pool) — self-healing: restarts miner on exit,
# so the container keeps a continuous foreground process.
set -u

# Debug override: any arguments replace the miner loop (e.g. SRBMiner-MULTI --help)
if [ "$#" -gt 0 ]; then exec "$@"; fi

# Required: f2pool mining username — f2pool pays the address bound to the account
F2POOL_USER="${F2POOL_USER:?set F2POOL_USER (your f2pool mining username)}"
# Worker name: prefix + container hostname suffix so every replica is unique
WORKER="${WORKER_PREFIX:-rental}-$(hostname | tail -c 8)"
# f2pool Pearl stratum (plain stratum on port 5500); wallet = USERNAME.WORKER
POOLS="${POOLS:-pearl.f2pool.com:5500}"
WALLET="${F2POOL_USER}.${WORKER}"

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
