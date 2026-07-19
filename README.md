<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/breuk-logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/breuk-logo-light.png">
  <img src="assets/breuk-logo-light.png" alt="Breuk — Corporate Lawyers" width="100%">
</picture>

# Breuk Agent

**The AI legal agent for your terminal, by [Breuk Legal](https://breuklegal.com).**

[![Latest release](assets/badge-release.svg)](https://github.com/Breuk-Legal/breuklegal-agent/releases/latest)
[![Platforms](assets/badge-platforms.svg)](#manual-download)
[![License](assets/badge-license.svg)](LICENSE.md)

</div>

---

Breuk Agent reasons over legal tasks and workflows and acts on your behalf — reading and drafting documents, running commands and connecting to your team's tools — all without leaving the terminal.

This repository distributes the official Breuk Agent binaries: [releases](https://github.com/Breuk-Legal/breuklegal-agent/releases), installation and the [changelog](CHANGELOG.md). The product's source code is proprietary and does not live here. Downloading is free; running Breuk Agent requires a Breuk account with an active subscription.

## Installation

### Linux and macOS

```sh
curl -fsSL https://breuklegal.com/install.sh | bash
```

Installs the latest version into `~/.breuk/bin/breuk` and adds the directory to your `PATH`.

To install a specific version:

```sh
curl -fsSL https://breuklegal.com/install.sh | VERSION=0.1.2 bash
```

### Windows

Download the `.zip` for your architecture from the [latest release](https://github.com/Breuk-Legal/breuklegal-agent/releases/latest), extract it and run `breuk.exe` from your terminal.

### Manual download

Every release publishes:

| Artifact | Platform |
|---|---|
| `breuk-linux-x86_64.tar.gz` / `breuk-linux-arm64.tar.gz` | Linux |
| `breuk-mac-x86_64.tar.gz` / `breuk-mac-arm64.tar.gz` | macOS |
| `breuk-windows-x86_64.zip` / `breuk-windows-arm64.zip` | Windows |
| `breuk-linux-{amd64,arm64}.deb` / `.rpm` | Linux packages |
| `checksums.txt` | SHA-256 of every artifact |

Verify integrity with `sha256sum -c` against `checksums.txt`.

## Getting started

```sh
breuk
```

On first run, Breuk Agent walks you through signing in with your Breuk account.

## License

The binaries distributed here are proprietary software. See [LICENSE.md](LICENSE.md).

## Support

Reach us through [breuklegal.com](https://breuklegal.com).
