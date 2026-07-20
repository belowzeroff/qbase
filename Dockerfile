# qbase test environment
#
# kdb+ is proprietary and is NOT redistributed in this image. Provide it either:
#   1. At build time via the KDB_DOWNLOAD_URL build arg (URL to the free Linux
#      kdb+ zip from https://kx.com/kdb-personal-edition-download/), or
#   2. At run time by mounting a licensed Linux kdb+ install at /opt/kdb.
#
# A license (kc.lic) must be present in QHOME (or the directory named by QLIC).

FROM debian:stable-slim

ARG KDB_DOWNLOAD_URL=""

RUN apt-get update \
    && apt-get install -y --no-install-recommends rlwrap unzip curl ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*

ENV QHOME=/opt/kdb
ENV PATH="${QHOME}/l64:${PATH}"

# Bake kdb+ in if a URL was supplied; otherwise expect /opt/kdb mounted at runtime.
RUN if [ -n "$KDB_DOWNLOAD_URL" ]; then \
        mkdir -p /tmp/kdb \
        && curl -fsSL "$KDB_DOWNLOAD_URL" -o /tmp/kdb/q.zip \
        && unzip -q /tmp/kdb/q.zip -d /opt \
        && mv /opt/q "$QHOME" \
        && rm -rf /tmp/kdb ; \
    fi

WORKDIR /qbase
COPY . /qbase

# Runs the test suite; container exit code = number of failing tests.
CMD ["bash", "tests/run.sh"]
