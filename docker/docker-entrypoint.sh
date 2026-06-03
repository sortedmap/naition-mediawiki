#!/bin/bash
set -e

cd /var/www/html

ensure_visual_editor() {
    if [ -f extensions/VisualEditor/extension.json ] \
        && [ -d extensions/VisualEditor/lib/ve/.git ]; then
        return 0
    fi
    echo "Installing VisualEditor extension (REL1_26)..."
    rm -rf extensions/VisualEditor
    git clone -b REL1_26 \
        https://gerrit.wikimedia.org/r/mediawiki/extensions/VisualEditor.git \
        extensions/VisualEditor
    cd extensions/VisualEditor
    git submodule update --init
    cd /var/www/html
    chown -R www-data:www-data extensions/VisualEditor
}

ensure_mediawiki_core() {
    if [ ! -f includes/cache/LocalisationCache.php ]; then
        echo "ERROR: missing includes/cache/ — incomplete MediaWiki tree in mediawiki/" >&2
        exit 1
    fi
    if [ ! -f resources/lib/oojs-ui/themes/mediawiki/images/icons/add.svg ]; then
        echo "ERROR: missing oojs-ui theme images (resources/lib/oojs-ui/themes/mediawiki/images/) — incomplete MediaWiki tree" >&2
        exit 1
    fi
}

ensure_runtime_dirs() {
    mkdir -p images cache
    chown -R www-data:www-data images cache
}

ensure_mediawiki_core
/docker/wait-for-db.sh
ensure_runtime_dirs
ensure_visual_editor

export MW_DB_SERVER="${MW_DB_SERVER:-db}"
export MW_DB_NAME="${MW_DB_NAME:-wikidb}"
export MW_DB_USER="${MW_DB_USER:-wikiuser}"
export MW_DB_PASSWORD="${MW_DB_PASSWORD:-wikipass}"
export MW_DB_PORT="${MW_DB_PORT:-3306}"
export MW_SERVER="${MW_SERVER:-http://localhost:8080}"
export MW_SCRIPT_PATH="${MW_SCRIPT_PATH:-}"
export MW_WIKI_NAME="${MW_WIKI_NAME:-MediaWiki}"
export MW_LANGUAGE="${MW_LANGUAGE:-en}"
if [ -z "$MW_SECRET_KEY" ]; then
    MW_SECRET_KEY="changeme-$(date +%s)-local-dev-only"
fi
export MW_SECRET_KEY
export MW_ADMIN_USER="${MW_ADMIN_USER:-admin}"
export MW_ADMIN_PASS="${MW_ADMIN_PASS:-adminpass}"
export PARSOID_URL="${PARSOID_URL:-http://parsoid:8142}"
export PARSOID_DOMAIN="${PARSOID_DOMAIN:-localhost}"
export PARSOID_PREFIX="${PARSOID_PREFIX:-localhost}"

render_localsettings() {
    envsubst '$MW_DB_SERVER $MW_DB_NAME $MW_DB_USER $MW_DB_PASSWORD $MW_SERVER $MW_SCRIPT_PATH $MW_WIKI_NAME $MW_LANGUAGE $MW_SECRET_KEY $PARSOID_URL $PARSOID_DOMAIN $PARSOID_PREFIX' \
        < /docker/LocalSettings.php.template > /var/www/html/LocalSettings.php
    chown www-data:www-data /var/www/html/LocalSettings.php
}

wiki_is_installed() {
    mysql -h"$MW_DB_SERVER" -P"$MW_DB_PORT" -u"$MW_DB_USER" -p"$MW_DB_PASSWORD" "$MW_DB_NAME" \
        -e "SELECT 1 FROM page LIMIT 1" 2>/dev/null | grep -q 1
}

if ! wiki_is_installed; then
    echo "Running MediaWiki installer..."
    rm -f /var/www/html/LocalSettings.php
    php maintenance/install.php \
        "$MW_WIKI_NAME" \
        "$MW_ADMIN_USER" \
        --pass "$MW_ADMIN_PASS" \
        --dbserver "$MW_DB_SERVER" \
        --dbname "$MW_DB_NAME" \
        --dbuser "$MW_DB_USER" \
        --dbpass "$MW_DB_PASSWORD" \
        --dbtype mysql \
        --scriptpath "$MW_SCRIPT_PATH" \
        --lang "$MW_LANGUAGE" \
        --installdbuser "$MYSQL_ROOT_USER" \
        --installdbpass "$MYSQL_ROOT_PASSWORD"
fi

render_localsettings

echo "Running database updates..."
php maintenance/update.php --quick --skip-external-dependencies 2>/dev/null \
    || php maintenance/update.php --quick

chown -R www-data:www-data /var/www/html/images /var/www/html/cache

echo "Starting PHP-FPM and Nginx..."
php-fpm -D
exec nginx -g 'daemon off;'
