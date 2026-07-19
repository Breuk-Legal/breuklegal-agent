# Breuk (CLI)

Agente de IA legal para la terminal, de [Breuk Legal](https://breuklegal.com).

Este repositorio distribuye los binarios oficiales de Breuk (CLI): [releases](https://github.com/Breuk-Legal/breuklegal-agent/releases), instalación y [changelog](CHANGELOG.md). El código fuente del producto es propietario y no vive aquí. Descargar es libre; para ejecutar Breuk (CLI) necesitas una cuenta Breuk con subscripción activa.

## Instalación

### Linux y macOS

```sh
curl -fsSL https://breuklegal.com/install.sh | bash
```

Instala la última versión en `~/.breuk/bin/breuk` y agrega el directorio a tu `PATH`.

Para instalar una versión específica:

```sh
curl -fsSL https://breuklegal.com/install.sh | VERSION=0.1.0 bash
```

### Windows

Descarga el `.zip` de tu arquitectura desde la [última release](https://github.com/Breuk-Legal/breuklegal-agent/releases/latest), descomprímelo y ejecuta `breuk.exe` desde tu terminal.

### Descarga manual

Cada release publica:

| Artefacto | Plataforma |
|---|---|
| `breuk-linux-x86_64.tar.gz` / `breuk-linux-arm64.tar.gz` | Linux |
| `breuk-mac-x86_64.tar.gz` / `breuk-mac-arm64.tar.gz` | macOS |
| `breuk-windows-x86_64.zip` / `breuk-windows-arm64.zip` | Windows |
| `breuk-linux-{amd64,arm64}.deb` / `.rpm` | Paquetes Linux |
| `checksums.txt` | SHA-256 de todos los artefactos |

Verifica la integridad con `sha256sum -c` contra `checksums.txt`.

## Primeros pasos

```sh
breuk
```

Al primer arranque, Breuk (CLI) te guía para autenticarte con tu cuenta Breuk.

## Soporte

Escríbenos a través de [breuklegal.com](https://breuklegal.com).
