#!/bin/bash
# Для преподавателя: синхронизировать mediawiki/ из монорепозитория курса.
# Ученикам этот скрипт не нужен — mediawiki/ уже в git-репозитории deploy.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$PROJECT_ROOT/mediawiki"
DEST="$SCRIPT_DIR/mediawiki"

if [ ! -d "$SRC" ]; then
    echo "Не найден каталог mediawiki: $SRC" >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    echo "Нужен rsync." >&2
    exit 1
fi

echo "Синхронизация: $SRC -> $DEST"
mkdir -p "$DEST"

rsync -a --delete \
    --exclude 'cache/*' \
    --exclude 'images/*' \
    --exclude 'LocalSettings.php' \
    --exclude 'LocalSettings.php5' \
    --exclude 'thumb/' \
    --exclude 'tmp/' \
    --exclude 'extensions/VisualEditor/' \
    "$SRC/" "$DEST/"

mkdir -p "$DEST/cache" "$DEST/images"
[ -f "$SRC/cache/.htaccess" ] && cp "$SRC/cache/.htaccess" "$DEST/cache/" 2>/dev/null || true
[ -f "$SRC/images/.htaccess" ] && cp "$SRC/images/.htaccess" "$DEST/images/" 2>/dev/null || true

echo "Готово. Закоммитьте изменения в deploy/ и запушьте на GitHub."
