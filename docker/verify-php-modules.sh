#!/bin/bash
# Compare php -m output with php-modules.txt (run inside app container)
set -e
MODULES_FILE="${1:-/var/www/html/../php-modules.txt}"
if [ ! -f "$MODULES_FILE" ]; then
    MODULES_FILE="/php-modules.txt"
fi
if [ ! -f "$MODULES_FILE" ]; then
    echo "php-modules.txt not found" >&2
    exit 1
fi

EXPECTED=$(grep -v '^\[' "$MODULES_FILE" | grep -v '^$' | sort)
ACTUAL=$(php -m | sort)
MISSING=0
while IFS= read -r mod; do
    if ! echo "$ACTUAL" | grep -qx "$mod"; then
        echo "MISSING: $mod"
        MISSING=$((MISSING + 1))
    fi
done <<< "$EXPECTED"

if [ "$MISSING" -eq 0 ]; then
    echo "All modules from php-modules.txt are loaded."
else
    echo "$MISSING module(s) missing."
    exit 1
fi
