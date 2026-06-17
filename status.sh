#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
docker compose ps
KEY="$(security find-generic-password -a "$USER" -s cliproxyapi-key -w 2>/dev/null)" || {
  echo "FAIL: Keychain entry missing (service=cliproxyapi-key)"; exit 1; }
curl -fsS -H "Authorization: Bearer $KEY" http://127.0.0.1:8317/v1/models >/dev/null \
  && echo "OK: CLIProxyAPI /v1/models reachable" || echo "FAIL"
