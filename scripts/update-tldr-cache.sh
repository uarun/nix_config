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

#... LANG_CODE, not LANG: LANG is the exported locale variable, and reassigning
#... it here would hand an invalid locale (e.g. "en") to curl and unzip.
LANG_CODE="${1:-en}"
CACHE_DIR="${TEALDEER_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tealdeer}/tldr-pages"
#... Each per-language zip holds the contents of one pages directory. Tealdeer
#... reads every language, English included, from pages.<lang>/.
SUB="pages.${LANG_CODE}"
URL="https://github.com/tldr-pages/tldr/releases/latest/download/tldr-pages.${LANG_CODE}.zip"
TMP=$(mktemp)
#... curl or unzip failing exits via `set -e`, so clean up on any exit, not just success.
trap 'rm -f "$TMP"' EXIT

echo "Downloading tldr pages (lang=${LANG_CODE})..."
curl -fSL -o "$TMP" "$URL"

#... Extract beside the old pages and swap only once unzip succeeds, so a bad
#... download keeps the previous cache.
echo "Extracting to ${CACHE_DIR}/${SUB}..."
mkdir -p "$CACHE_DIR"
NEW=$(mktemp -d "$CACHE_DIR/.${SUB}.XXXXXX")
trap 'rm -f "$TMP"; rm -rf "$NEW"' EXIT
unzip -o "$TMP" -d "$NEW" > /dev/null
rm -rf "${CACHE_DIR:?}/$SUB"
mv "$NEW" "$CACHE_DIR/$SUB"

echo "Done. tldr cache updated."
