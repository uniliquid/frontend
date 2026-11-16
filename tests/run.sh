#!/bin/sh
# Runs the tests in Docker: ./tests/run.sh (exit status 0 = all passed).
# The image builds WebMCP and fetches core at the commits below (network
# access at build time only); the tests run the frontend of this checkout
# as CGI against PostgreSQL in the container. Synthetic data only.
set -eu
cd "$(dirname "$0")/.."
# uniliquid/webmcp and uniliquid/core with the session additions.
WEBMCP_COMMIT=${WEBMCP_COMMIT:-0b044c2688f2eb78b3f5242b7d06f617f933e84e}
CORE_COMMIT=${CORE_COMMIT:-32c6e66d996d220dd33d5b74062ed8f8fd79b7c0}
image="frontend-tests:$WEBMCP_COMMIT-$CORE_COMMIT"
docker build -q -t "$image" --build-arg WEBMCP_COMMIT="$WEBMCP_COMMIT" \
    --build-arg CORE_COMMIT="$CORE_COMMIT" tests >/dev/null
docker run --rm --network none -v "$PWD:/src:ro" "$image" sh /src/tests/in-container.sh
