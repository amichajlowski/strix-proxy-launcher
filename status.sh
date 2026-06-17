#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
docker compose ps
if [[ -n "${STRIX_PROXY_API_KEY:-}" ]]; then
  KEY="$STRIX_PROXY_API_KEY"
elif [[ -n "${LLM_API_KEY:-}" ]]; then
  KEY="$LLM_API_KEY"
elif command -v security >/dev/null 2>&1; then
  KEY="$(security find-generic-password -a "${USER:-$(id -un 2>/dev/null || printf user)}" -s cliproxyapi-key -w 2>/dev/null)" || {
    echo "FAIL: API key missing. Set STRIX_PROXY_API_KEY or add macOS Keychain entry."; exit 1; }
else
  echo "FAIL: API key missing. Set STRIX_PROXY_API_KEY or LLM_API_KEY."; exit 1
fi
BASE="${STRIX_PROXY_BASE:-${LLM_API_BASE:-http://127.0.0.1:8317/v1}}"
BASE="${BASE%/}"
curl -fsS -H "Authorization: Bearer $KEY" "$BASE/models" >/dev/null \
  && echo "OK: CLIProxyAPI /v1/models reachable" || echo "FAIL"
