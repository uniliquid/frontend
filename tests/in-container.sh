#!/bin/sh
# Test only, run by tests/run.sh inside the test image: a PostgreSQL 17
# cluster with core.sql and session.sql, the frontend copied to /app with
# the test configuration, then tests/session-test.py.
set -eu
pg_ctlcluster 17 main start
runuser -u postgres -- psql -X -q -v ON_ERROR_STOP=1 <<'SQL'
CREATE ROLE root LOGIN;
CREATE DATABASE liquid_feedback OWNER root;
SQL
PGOPTIONS='-c client_min_messages=warning' psql -X -q -v ON_ERROR_STOP=1 -d liquid_feedback -f /opt/core/core.sql
PGOPTIONS='-c client_min_messages=warning' psql -X -q -v ON_ERROR_STOP=1 -d liquid_feedback -f /opt/core/session.sql
runuser -u postgres -- psql -X -q -v ON_ERROR_STOP=1 -d liquid_feedback -c 'CREATE EXTENSION pgcrypto'
cp -a /src /app
rm -rf /app/.git
cp /src/tests/config.lua /app/config/test.lua
exec python3 /src/tests/session-test.py
