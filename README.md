<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/breuk-logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/breuk-logo-light.png">
  <img src="assets/breuk-logo-light.png" alt="Breuk — Corporate Lawyers" width="100%">
</picture>

# Breuk Agent

**The AI legal agent by [Breuk Legal](https://breuklegal.com).**

[![Latest release](assets/badge-release.svg)](https://github.com/Breuk-Legal/breuklegal-agent/releases)
[![Platforms](assets/badge-platforms.svg)](#requirements)
[![License](assets/badge-license.svg)](LICENSE.md)

</div>

---

Breuk Agent reasons over legal tasks and workflows and acts on your behalf — reading and drafting documents, running commands and connecting to your team's tools.

This repository distributes the official Breuk Agent application: [releases](https://github.com/Breuk-Legal/breuklegal-agent/releases) and installation. The product's source code is proprietary and does not live here. Downloading is free; running Breuk Agent requires a Breuk account with an active subscription.

## Installation

Open a terminal and run one command. No administrator privileges are required and nothing is written outside your home directory — the installer verifies the download against the checksum published with it, places the application in `~/.local/bin` and adds it to your applications menu.

### Linux

```sh
curl -fsSL https://breuklegal.com/install.sh | bash
```

Then open **Breuk Agent** from your applications menu.

### macOS and Windows

Not published yet. Both are coming; write to us at [breuklegal.com](https://breuklegal.com) if you need one of them — knowing how many people ask is what moves the date.

### Requirements

| Platform | Supported | Also needed |
|---|---|---|
| Linux | x86_64 | FUSE (`libfuse2`) — the installer checks for it and tells you how to install it |
| macOS | Not yet | — |
| Windows | Not yet | — |

Breuk Agent ships everything it needs to draw its own window, so there is no system webview or toolkit to install.

### A specific version

```sh
curl -fsSL https://breuklegal.com/install.sh | VERSION=1.0.0-beta.1 bash
```

### Manual download

Every release publishes:

| Artifact | What it is |
|---|---|
| `Breuk-Agent.AppImage` | The application, for Linux x86_64 |
| `latest-linux.yml` | The release's version and the SHA-512 of the application |

Download both, check the file against the `sha512` field in the metadata, then make it executable and run it:

```sh
openssl dgst -sha512 -binary Breuk-Agent.AppImage | openssl base64 -A
chmod +x Breuk-Agent.AppImage
./Breuk-Agent.AppImage
```

The file name carries no version on purpose: Breuk Agent replaces it in place when it updates itself, so your launcher and your menu entry keep working.

## Getting started

Open **Breuk Agent** from your applications menu, or run it from where the installer left it:

```sh
~/.local/bin/Breuk-Agent.AppImage
```

The first time, the window shows a link and a code before anything else. Open the link in your browser, confirm the code matches, and this machine is authorized. You only sign in once.

Running Breuk Agent requires a Breuk account with an active subscription.

## Updates

Breuk Agent keeps itself up to date. It checks for a new version when it starts and every few hours while it is open, downloads it in the background, and applies it when you close the window. Nothing interrupts you and nothing asks you anything.

## License

The application distributed here is proprietary software. See [LICENSE.md](LICENSE.md).

## Support

Reach us through [breuklegal.com](https://breuklegal.com).
