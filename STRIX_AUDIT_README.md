# Strix Audit Quick Start

This guide is for local users running Strix through the shared `strix-proxy` launcher on Kali Linux.

## Before You Start

Confirm the launcher works:

```bash
strix-proxy --version
```

If this fails, contact the system owner. Normal users should not need to configure API keys, Docker, or Codex OAuth manually.

Use Strix only on authorised targets. Do not include personal data, secrets, customer data, or production credentials in prompts or uploaded materials.

## Basic Command Format

```bash
strix-proxy -t <target> --scan-mode <mode> -n
```

Common modes:

```bash
--scan-mode quick
--scan-mode standard
--scan-mode deep
```

Reasoning effort can be controlled with:

```bash
STRIX_REASONING_EFFORT=medium
STRIX_REASONING_EFFORT=high
STRIX_REASONING_EFFORT=xhigh
```

Recommended defaults:

```bash
# Medium/balanced audit
STRIX_REASONING_EFFORT=medium strix-proxy -t <target> --scan-mode standard -n

# Deeper audit
STRIX_REASONING_EFFORT=high strix-proxy -t <target> --scan-mode deep -n
```

Use `xhigh` only for high-value or high-risk assessments because it is slower and more expensive.

## Source Code Audit

Use this for local repositories, application source code, scripts, IaC, CI/CD definitions, and configuration files.

Medium scan:

```bash
STRIX_REASONING_EFFORT=medium \
strix-proxy -t /path/to/repository --scan-mode standard -n
```

Deep scan:

```bash
STRIX_REASONING_EFFORT=high \
strix-proxy -t /path/to/repository --scan-mode deep -n
```

Focused source review:

```bash
strix-proxy \
  -t /path/to/repository \
  --scan-mode deep \
  --instruction "Focus on authentication, authorisation, injection, insecure deserialisation, secrets exposure, SSRF, path traversal, and unsafe file handling." \
  -n
```

Typical source code targets:

```bash
strix-proxy -t ~/projects/web-app --scan-mode standard -n
strix-proxy -t ~/projects/api-service --scan-mode deep -n
strix-proxy -t ~/projects/terraform --scan-mode standard -n
```

## Web Application Audit

Use this for authorised web applications, staging systems, lab targets, and internal test environments.

Medium web audit:

```bash
STRIX_REASONING_EFFORT=medium \
strix-proxy -t https://target.example.test --scan-mode standard -n
```

Deep web audit:

```bash
STRIX_REASONING_EFFORT=high \
strix-proxy -t https://target.example.test --scan-mode deep -n
```

Authentication and access-control focus:

```bash
strix-proxy \
  -t https://target.example.test \
  --scan-mode deep \
  --instruction "Focus on authentication bypass, session management, broken access control, IDOR, privilege escalation, CSRF, and insecure direct object access." \
  -n
```

Input validation focus:

```bash
strix-proxy \
  -t https://target.example.test \
  --scan-mode standard \
  --instruction "Focus on SQL injection, command injection, XSS, SSRF, path traversal, template injection, and unsafe file upload." \
  -n
```

## API Audit

Use this for REST, GraphQL, OpenAPI-described APIs, internal services, and gateway endpoints.

API endpoint scan:

```bash
strix-proxy -t https://api.target.example.test --scan-mode standard -n
```

OpenAPI specification scan:

```bash
strix-proxy -t /path/to/openapi.yaml --scan-mode deep -n
```

API-focused deep scan:

```bash
strix-proxy \
  -t https://api.target.example.test \
  --scan-mode deep \
  --instruction "Focus on broken object-level authorisation, broken function-level authorisation, mass assignment, excessive data exposure, rate limiting, replay risks, and unsafe error disclosure." \
  -n
```

GraphQL focus:

```bash
strix-proxy \
  -t https://api.target.example.test/graphql \
  --scan-mode deep \
  --instruction "Focus on introspection exposure, query depth abuse, batching abuse, authorisation bypass, IDOR, and sensitive field exposure." \
  -n
```

## Network Audit

Use this only for authorised IP ranges and lab networks.

Single host:

```bash
strix-proxy -t 10.10.10.25 --scan-mode standard -n
```

Small subnet:

```bash
strix-proxy -t 10.10.10.0/24 --scan-mode standard -n
```

Deep network assessment:

```bash
STRIX_REASONING_EFFORT=high \
strix-proxy -t 10.10.10.0/24 --scan-mode deep -n
```

Service exposure focus:

```bash
strix-proxy \
  -t 10.10.10.0/24 \
  --scan-mode standard \
  --instruction "Focus on exposed management interfaces, weak TLS, default services, unsafe admin panels, outdated software, and lateral movement paths." \
  -n
```

Internal network hygiene:

```bash
strix-proxy \
  -t 10.10.20.0/24 \
  --scan-mode standard \
  --instruction "Identify unnecessary exposed services, risky protocols, cleartext authentication, weak segmentation, and systems requiring manual validation." \
  -n
```

## Cloud And Infrastructure Audit

Use this for local infrastructure-as-code folders and exported cloud configuration evidence.

Terraform:

```bash
strix-proxy -t /path/to/terraform --scan-mode deep -n
```

Kubernetes manifests:

```bash
strix-proxy -t /path/to/k8s-manifests --scan-mode standard -n
```

Docker Compose and containers:

```bash
strix-proxy -t /path/to/docker-project --scan-mode standard -n
```

Cloud/IaC focus:

```bash
strix-proxy \
  -t /path/to/infrastructure \
  --scan-mode deep \
  --instruction "Focus on public exposure, over-permissive IAM, missing encryption, insecure secrets handling, weak network segmentation, unsafe container privileges, and audit logging gaps." \
  -n
```

## Secrets And Configuration Audit

Use this for repositories, deployment folders, CI/CD files, and local config bundles.

```bash
strix-proxy \
  -t /path/to/project \
  --scan-mode standard \
  --instruction "Focus on hardcoded secrets, tokens, API keys, private keys, insecure defaults, debug flags, overly broad CORS, weak TLS settings, and sensitive data in logs." \
  -n
```

If real secrets are found, rotate them. Do not paste secret values into reports or tickets.

## Quick Triage Pattern

For a fast first pass:

```bash
STRIX_REASONING_EFFORT=medium \
strix-proxy -t <target> --scan-mode quick -n
```

For meaningful security review:

```bash
STRIX_REASONING_EFFORT=medium \
strix-proxy -t <target> --scan-mode standard -n
```

For high-risk systems:

```bash
STRIX_REASONING_EFFORT=high \
strix-proxy -t <target> --scan-mode deep -n
```

For critical systems where cost and runtime are acceptable:

```bash
STRIX_REASONING_EFFORT=xhigh \
strix-proxy -t <target> --scan-mode deep -n
```

## Reporting Guidance

When reviewing Strix output, prioritise:

- Exploitability and business impact.
- Authentication and authorisation weaknesses.
- Internet-facing exposure.
- Data exposure and privacy risk.
- Secrets or credentials requiring rotation.
- Findings requiring manual validation.

For GDPR/CCPA-sensitive work:

- Replace personal data with `XXXX`.
- Do not include raw tokens, session IDs, private keys, or customer data.
- Avoid storing scan output in shared locations unless approved.
- Use authorised test data wherever possible.

## Troubleshooting

Check proxy health:

```bash
strix-proxy --version
```

Check Docker image:

```bash
docker image ls | grep strix
```

Check local proxy models:

```bash
source /etc/strix-proxy.env
curl -fsS \
  -H "Authorization: Bearer $STRIX_PROXY_API_KEY" \
  "$STRIX_PROXY_BASE/models" | head
```

If the Codex session expires, ask the system owner to renew OAuth:

```bash
cd /opt/strix-proxy-launcher
sudo docker compose exec cli-proxy-api /CLIProxyAPI/CLIProxyAPI -no-browser --codex-login
```

