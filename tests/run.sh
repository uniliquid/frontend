#!/bin/sh
# Runs the tests in Docker: ./tests/run.sh (exit status 0 = all passed).
# The image builds WebMCP and fetches core at the commits below (network
# access at build time only); the tests run the frontend of this checkout
# as CGI against PostgreSQL in the container. Synthetic data only.
set -eu
cd "$(dirname "$0")/.."
# uniliquid/webmcp and uniliquid/core with the session additions.
WEBMCP_COMMIT=${WEBMCP_COMMIT:-04da3e4dc751be14730061477f977b08af386584}
CORE_COMMIT=${CORE_COMMIT:-f0f5e1763a8e89b0585adcafed25ce72f9b7d06a}
image="frontend-tests:$WEBMCP_COMMIT-$CORE_COMMIT"
docker build -q -t "$image" --build-arg WEBMCP_COMMIT="$WEBMCP_COMMIT" \
    --build-arg CORE_COMMIT="$CORE_COMMIT" tests >/dev/null
docker run --rm --network none -v "$PWD:/src:ro" "$image" sh /src/tests/in-container.sh
