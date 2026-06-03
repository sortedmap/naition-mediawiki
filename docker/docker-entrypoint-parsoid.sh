#!/bin/bash
set -e

export PARSOID_MW_API_URL="${PARSOID_MW_API_URL:-http://app/api.php}"
export PARSOID_DOMAIN="${PARSOID_DOMAIN:-localhost}"
export PARSOID_PREFIX="${PARSOID_PREFIX:-localhost}"

cd /opt/parsoid

# Wait for MediaWiki API
max=120
elapsed=0
echo "Waiting for MediaWiki API at ${PARSOID_MW_API_URL}..."
while ! curl -sf "${PARSOID_MW_API_URL}?action=query&meta=siteinfo" >/dev/null 2>&1; do
    sleep 3
    elapsed=$((elapsed + 3))
    if [ "$elapsed" -ge "$max" ]; then
        echo "MediaWiki API not ready in ${max}s, starting Parsoid anyway..." >&2
        break
    fi
done

envsubst '$PARSOID_MW_API_URL $PARSOID_DOMAIN' \
    < /docker/parsoid.config.yaml.template > /opt/parsoid/config.yaml
echo "Starting Parsoid..."
exec npm start
