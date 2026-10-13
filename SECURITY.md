# Security Policy

## Supported Versions

We support the **latest release** and the active development branch with
security updates. We use [semantic versioning](https://semver.org/)
(MAJOR.MINOR.PATCH).

| Version | Supported |
| ------- | --------- |
| Latest release | :white_check_mark: |
| Older releases | :x: |

When a vulnerability is fixed, we release a new patch version. Please upgrade
to the latest release to receive security fixes.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

- **Preferred:** Use [GitHub Security Advisories (gghstats-xui-selfhosted)](https://github.com/hrodrig/gghstats-xui-selfhosted/security/advisories/new) for issues in this repository (Compose, Helm, env templates, docs, deployment layout).
- **Dashboard image / BFF:** report via [gghstats-xui Security Advisories](https://github.com/hrodrig/gghstats-xui/security/advisories/new) when the flaw is in the app itself, not the manifests here.
- **Backend image:** report via [gghstats Security Advisories](https://github.com/hrodrig/gghstats/security/advisories/new).
- **Alternative:** Contact the maintainer via [github.com/hrodrig](https://github.com/hrodrig) with:
  - clear description
  - impact
  - steps to reproduce

## What to expect

- We acknowledge your report as soon as possible.
- We investigate and work on a fix.
- For accepted reports, we coordinate disclosure and credit (unless you prefer anonymity).
