# Pearl (pearlhash) miner image for SaladCloud — SRBMiner-MULTI, pinned version.
# Config comes from environment variables at runtime (see entrypoint.sh);
# the image itself contains no wallet, e-mail or secrets, so it can be public.
FROM ubuntu:22.04

ARG SRB_VERSION=3.8.4
# CA bundle for curl. Default is the distro bundle; on Clio's VM the build
# overrides this with the egress-proxy CA (see PLAN.md build notes).
ARG CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Official release only (github.com/doktor83/SRBMiner-Multi), MD5 verified at build time
RUN mkdir -p /opt/srbminer \
 && cd /tmp \
 && V=$(echo "${SRB_VERSION}" | tr '.' '-') \
 && F="SRBMiner-Multi-${V}-Linux.tar.gz" \
 && curl --cacert "${CURL_CA_BUNDLE}" -fsSL -o "${F}" "https://github.com/doktor83/SRBMiner-Multi/releases/download/${SRB_VERSION}/${F}" \
 && curl --cacert "${CURL_CA_BUNDLE}" -fsSL -o srb.md5 "https://github.com/doktor83/SRBMiner-Multi/releases/download/${SRB_VERSION}/$(echo "${F}" | sed 's/\.gz$//').md5" \
 && tr -d '\r' < srb.md5 > srb.clean.md5 \
 && md5sum -c srb.clean.md5 \
 && tar -xzf "${F}" -C /opt/srbminer --strip-components=1 \
 && /opt/srbminer/SRBMiner-MULTI --help > /dev/null \
 && rm -f "${F}" srb.md5 srb.clean.md5

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
