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

Open a terminal and run one command. No administrator privileges required — the installer verifies the SHA-256 checksum, places the binary in your home directory and adds it to your `PATH`.

### Linux

```sh
curl -fsSL https://breuklegal.com/install.sh | bash
```

### macOS

```sh
curl -fsSL https://breuklegal.com/install.sh | bash
```

### Windows

In PowerShell:

```powershell
irm https://breuklegal.com/install.ps1 | iex
```

### Requirements

| Platform | Supported | Also needed |
|---|---|---|
| Linux | x86_64 | WebKitGTK (`libwebkit2gtk-4.1`) — the installer checks for it and tells you how to install it |
| macOS | Apple Silicon (M1 or later) | Nothing; the system webview is built in |
| Windows | 10 / 11, x86_64 | WebView2 Runtime — preinstalled on Windows 11 and on any machine with an up-to-date Edge |

Breuk Agent is a desktop application, so it needs your system's webview. Intel Macs, and arm64 on Linux and Windows, are not published yet.

### A specific version

```sh
curl -fsSL https://breuklegal.com/install.sh | VERSION=0.1.21 bash
```

```powershell
$env:VERSION = "0.1.21"; irm https://breuklegal.com/install.ps1 | iex
```

### Manual download

Every release publishes:

| Artifact | Platform |
|---|---|
| `breuk-linux-x86_64.tar.gz` | Linux x86_64 |
| `breuk-mac-arm64.tar.gz` | macOS Apple Silicon |
| `breuk-windows-x86_64.zip` | Windows x86_64 |
| `checksums.txt` | SHA-256 of every artifact |

Verify integrity with `sha256sum -c` against `checksums.txt`, then place the binary anywhere on your `PATH`.

## Getting started

One command, identical on every platform:

```sh
breuk
```

The first time, the terminal prints a link and a code before anything else opens. Open the link in your browser, confirm the code matches, and this machine is authorized — then the Breuk Agent window opens. You only sign in once; every later `breuk` goes straight to the window.

To sign in without starting the app — or to sign in again after revoking a session:

```sh
breuk login
breuk logout
```

Running Breuk Agent requires a Breuk account with an active subscription.

## License

The binaries distributed here are proprietary software. See [LICENSE.md](LICENSE.md).

## Support

Reach us through [breuklegal.com](https://breuklegal.com).
