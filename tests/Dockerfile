# Test environment for tests/run.sh: Debian 13 with PostgreSQL 17, Lua 5.1,
# WebMCP (the uniliquid/webmcp framework with the C libraries and the
# accelerator built from the upstream WebMCP 1.2.5 release, as the
# deployment builds them) and LiquidFeedback core (core.sql, session.sql).
# The frontend under test is mounted at run time. Synthetic data only.
FROM debian:trixie@sha256:9c6e381421d0f48d1b8133e573f33c185ee16cbf505eda9c4a8a4791b25ea8a6
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl git \
       lua5.1 liblua5.1-0-dev libpq-dev postgresql-17 postgresql-server-dev-17 python3 \
    && rm -rf /var/lib/apt/lists/*

# The upstream release (pinned by SHA-256) for the C libraries; built with
# the Debian 13 include paths and GCC 14 (the deployment patches the same).
ARG WEBMCP_LIBS_URL=https://www.public-software-group.org/pub/projects/webmcp/v1.2.5/webmcp-v1.2.5.tar.gz
ARG WEBMCP_LIBS_SHA256=16bf5096f4754d56a6f7e059963cd8bc759c406ab50812e49252d97007666da3
# The framework and the database schema under test (full commits).
ARG WEBMCP_REPO=https://github.com/uniliquid/webmcp.git
ARG WEBMCP_COMMIT
ARG CORE_REPO=https://github.com/uniliquid/core.git
ARG CORE_COMMIT
RUN set -eu; \
    test -n "$WEBMCP_COMMIT" && test -n "$CORE_COMMIT"; \
    mkdir -p /build && cd /build; \
    curl -fsSL -o webmcp.tar.gz "$WEBMCP_LIBS_URL"; \
    echo "$WEBMCP_LIBS_SHA256  webmcp.tar.gz" | sha256sum -c -; \
    tar -xzf webmcp.tar.gz; \
    cd webmcp-v1.2.5; \
    cflags="-O2 -D_GNU_SOURCE -fPIC -Wall -I /usr/include/lua5.1 -Wno-error=incompatible-pointer-types"; \
    pgflags="-I $(pg_config --includedir) -I $(pg_config --includedir-server)"; \
    for dir in libraries/extos libraries/mondelefant libraries/multirand framework/accelerator; do \
      make -C "$dir" CFLAGS="$cflags" CFLAGS_PGSQL="$pgflags"; \
    done; \
    git init -q /opt/webmcp && cd /opt/webmcp; \
    git fetch -q --depth 1 "$WEBMCP_REPO" "$WEBMCP_COMMIT" && git checkout -q FETCH_HEAD; \
    cp /build/webmcp-v1.2.5/libraries/extos/extos.so /build/webmcp-v1.2.5/libraries/mondelefant/mondelefant_native.so \
       /build/webmcp-v1.2.5/libraries/multirand/multirand.so lib/; \
    mkdir -p accelerator && cp /build/webmcp-v1.2.5/framework/accelerator/webmcp_accelerator.so accelerator/; \
    git init -q /opt/core && cd /opt/core; \
    git fetch -q --depth 1 "$CORE_REPO" "$CORE_COMMIT" && git checkout -q FETCH_HEAD; \
    rm -rf /build
