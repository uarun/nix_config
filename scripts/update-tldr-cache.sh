#!/usr/bin/env bash
# Manually update tealdeer (tldr) cache.
#
# Tealdeer is built with rustls + webpki-roots, so it only trusts
# Mozilla's built-in CA bundle and ignores SSL_CERT_FILE.  Behind a
# corporate proxy that injects its own CA, `tldr --update` fails with
# InvalidCertificate(UnknownIssuer).
#
# This script uses curl (which respects the system CA bundle) to
# download the pages and extract them into tealdeer's cache directory.
set -euo pipefail

LANG="${1:-en}"
CACHE_DIR="${HOME}/.cache/tealdeer/tldr-pages"
URL="https://github.com/tldr-pages/tldr/releases/latest/download/tldr-pages.${LANG}.zip"
TMP=$(mktemp)

echo "Downloading tldr pages (lang=${LANG})..."
curl -fSL -o "$TMP" "$URL"

echo "Extracting to ${CACHE_DIR}..."
mkdir -p "$CACHE_DIR"
unzip -o "$TMP" -d "$CACHE_DIR" > /dev/null

rm -f "$TMP"
echo "Done. tldr cache updated."
