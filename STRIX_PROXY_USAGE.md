# Strix Proxy Launcher Usage

`strix-proxy` launches Strix through a local CLIProxyAPI service. It checks that the local proxy is running, verifies the proxy API key, confirms the Codex OAuth session works, and then starts Strix with OpenAI-compatible environment variables.

## Requirements

- Docker with the Compose plugin.
- A valid CLIProxyAPI `config.yaml`.
- A proxy API key listed in `config.yaml` under `api-keys`.
- A valid Codex OAuth login inside the CLIProxyAPI auth store.
- The Strix binary installed and executable.

Default paths and values:

```bash
PROXY_DIR=<directory containing strix-proxy>
STRIX_BIN=$HOME/.strix/bin/strix
STRIX_PROXY_BASE=http://127.0.0.1:8317/v1
STRIX_PROXY_MODEL=gpt-5.5
```

## Authentication Model

There are two authentication layers:

1. Strix authenticates to the local CLIProxyAPI service with a proxy API key.
2. CLIProxyAPI authenticates upstream using a Codex OAuth token stored in `auths/codex-*.json`.

The launcher resolves the proxy API key in this order:

1. `STRIX_PROXY_API_KEY`
2. `LLM_API_KEY`
3. macOS Keychain, when available

The launcher resolves the proxy base URL in this order:

1. `STRIX_PROXY_BASE`
2. `LLM_API_BASE`
3. `http://127.0.0.1:8317/v1`

## macOS Setup

You can use either environment variables or macOS Keychain.

Environment variable option:

```bash
export STRIX_PROXY_API_KEY='XXXX'
export STRIX_PROXY_BASE='http://127.0.0.1:8317/v1'
./strix-proxy --version
```

Keychain option:

```bash
security add-generic-password \
  -a "$USER" \
  -s cliproxyapi-key \
  -w 'XXXX' \
  -U
```

Then run:

```bash
./strix-proxy --version
```

## Linux/Kali Setup

Linux does not use macOS Keychain, so supply the proxy API key through the environment:

```bash
export STRIX_PROXY_API_KEY='XXXX'
export STRIX_PROXY_BASE='http://127.0.0.1:8317/v1'
export STRIX_BIN="$HOME/.strix/bin/strix"
```

Then run:

```bash
./strix-proxy --version
```

If your Strix binary is elsewhere:

```bash
STRIX_BIN=/opt/strix/strix ./strix-proxy --version
```

## Codex OAuth Session

The proxy API key only authenticates Strix to CLIProxyAPI. CLIProxyAPI still needs a valid Codex OAuth token.

The launcher checks for a token inside the container:

```text
/root/.cli-proxy-api/codex-*.json
```

This maps to the host folder:

```text
./auths/codex-*.json
```

If the token is missing or expired, `strix-proxy` starts interactive login:

```bash
docker compose -f docker-compose.yml \
  exec cli-proxy-api /CLIProxyAPI/CLIProxyAPI \
  -no-browser --codex-login
```

Follow the printed authorisation URL, sign in, copy the full redirect URL, and paste it back into the terminal.

## Usage Examples

Quick local repository scan:

```bash
./strix-proxy -t /path/to/repo --scan-mode quick -n
```

Deep scan with automatic higher reasoning effort:

```bash
./strix-proxy -t /path/to/repo --scan-mode deep -n
```

Deep scan with explicit maximum reasoning effort:

```bash
STRIX_REASONING_EFFORT=xhigh ./strix-proxy -t /path/to/repo -m deep -n
```

Lower-cost quick run:

```bash
STRIX_PROXY_EFFORT=low ./strix-proxy -t /path/to/repo -m quick -n
```

Remote target with a focused instruction:

```bash
./strix-proxy \
  -t https://example.com \
  --instruction "Focus on authentication, authorisation, and IDOR risks"
```

Use a different proxy model:

```bash
STRIX_PROXY_MODEL=gpt-5.4 ./strix-proxy -t /path/to/repo -m standard
```

Skip the live token probe:

```bash
STRIX_PROXY_PROBE=0 ./strix-proxy -t /path/to/repo -m quick
```

Only skip the probe when you are confident the Codex OAuth session is valid.

## Health Check

Check Docker Compose status and `/v1/models` reachability:

```bash
./status.sh
```

On Linux/Kali:

```bash
STRIX_PROXY_API_KEY='XXXX' ./status.sh
```

With a custom base URL:

```bash
STRIX_PROXY_API_KEY='XXXX' \
STRIX_PROXY_BASE='http://127.0.0.1:8317/v1' \
./status.sh
```

## Useful Environment Variables

| Variable | Purpose |
| --- | --- |
| `PROXY_DIR` | Directory containing `docker-compose.yml` and CLIProxyAPI config. |
| `STRIX_BIN` | Path to the Strix executable. |
| `STRIX_PROXY_API_KEY` | Preferred proxy API key variable, especially on Linux/Kali. |
| `LLM_API_KEY` | Compatible fallback API key variable. |
| `STRIX_PROXY_BASE` | Preferred proxy base URL. |
| `LLM_API_BASE` | Compatible fallback base URL. |
| `STRIX_PROXY_MODEL` | Model sent to CLIProxyAPI. |
| `STRIX_PROXY_PROBE` | Set to `0` to skip live token probing. |
| `STRIX_PROXY_EFFORT` | Wrapper-specific reasoning level: `low`, `medium`, `high`, or `xhigh`. |
| `STRIX_REASONING_EFFORT` | Reasoning level also exported to the Strix child process. |
| `STRIX_PROXY_KEYCHAIN_SERVICE` | macOS Keychain service name. |
| `STRIX_PROXY_KEYCHAIN_ACCOUNT` | macOS Keychain account name. |

## Operational Notes

- The Docker Compose file binds service ports to `127.0.0.1`, not all network interfaces.
- Do not place real API keys in shell history, documentation, screenshots, tickets, or shared chat logs.
- Prefer environment variables or a local secret manager on Linux/Kali.
- Prefer macOS Keychain on macOS if you do not want to export the key in your shell.
- The launcher exports `LLM_API_KEY` only to the Strix child process.
- If a probe fails, the launcher treats the Codex OAuth session as invalid and requests login again.

