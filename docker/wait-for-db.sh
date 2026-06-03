#!/bin/bash
set -e

host="${MW_DB_SERVER:-db}"
port="${MW_DB_PORT:-3306}"
user="${MYSQL_ROOT_USER:-root}"
pass="${MYSQL_ROOT_PASSWORD}"
max="${WAIT_DB_TIMEOUT:-120}"
elapsed=0

echo "Waiting for MySQL at ${host}:${port}..."
while ! mysqladmin ping -h"$host" -P"$port" -u"$user" -p"$pass" --silent 2>/dev/null; do
    sleep 2
    elapsed=$((elapsed + 2))
    if [ "$elapsed" -ge "$max" ]; then
        echo "MySQL did not become ready in ${max}s" >&2
        exit 1
    fi
done
echo "MySQL is ready."
