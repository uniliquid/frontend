#!/bin/sh
# Runs the tests in Docker: ./tests/run.sh (exit status 0 = all passed).
# The image builds WebMCP and fetches core at the commits below (network
# access at build time only); the tests run the frontend of this checkout
# as CGI against PostgreSQL in the container. Synthetic data only.
set -eu
cd "$(dirname "$0")/.."
# uniliquid/webmcp and uniliquid/core with the session additions.
WEBMCP_COMMIT=${WEBMCP_COMMIT:-59b9ca5a5a2c2d7aaad22a597948835ecb226cae}
CORE_COMMIT=${CORE_COMMIT:-3d55170f41a6c0a23729331ef63db0d876fcef5b}
image="frontend-tests:$WEBMCP_COMMIT-$CORE_COMMIT"
docker build -q -t "$image" --build-arg WEBMCP_COMMIT="$WEBMCP_COMMIT" \
    --build-arg CORE_COMMIT="$CORE_COMMIT" tests >/dev/null
docker run --rm --network none -v "$PWD:/src:ro" "$image" sh /src/tests/in-container.sh
