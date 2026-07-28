# Breuk Agent — instalador para Windows
#
#   irm https://breuklegal.com/install.ps1 | iex
#
# Para fijar una versión:  $env:VERSION = "0.1.21"; irm https://breuklegal.com/install.ps1 | iex
#
# Espejo de install.sh: resuelve la última versión, descarga el .zip de la
# release, verifica el SHA-256 contra checksums.txt, instala en
# %USERPROFILE%\.breuk\bin y agrega ese directorio al PATH del usuario.
#
# Todo vive dentro de una función porque el script se ejecuta vía `iex`: un
# `exit` suelto cerraría la ventana de PowerShell del usuario en vez de
# terminar el instalador.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Install-BreukAgent {
    $app = 'breuk'
    $repo = 'Breuk-Legal/breuklegal-agent'
    $installDir = Join-Path $env:USERPROFILE '.breuk\bin'

    function Write-Info    ($m) { Write-Host $m -ForegroundColor Green }
    function Write-Warn    ($m) { Write-Host $m -ForegroundColor Yellow }
    function Write-Failure ($m) { Write-Host $m -ForegroundColor Red }

    # Invoke-WebRequest en Windows PowerShell 5.1 pinta una barra de progreso
    # que puede multiplicar por diez el tiempo de una descarga de 10 MB.
    $ProgressPreference = 'SilentlyContinue'
    # Windows PowerShell 5.1 no negocia TLS 1.2 por default en instalaciones
    # viejas, y tanto la API de GitHub como sus descargas lo exigen.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Solo se publica un .zip x86_64. En Windows on ARM el binario corre bajo
    # la emulación x64 del sistema, así que se avisa y se sigue en vez de
    # negar la instalación por una incompatibilidad que el OS resuelve.
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq 'ARM64') {
        Write-Warn 'Windows ARM64 detectado: se instala la version x86_64, que corre bajo emulacion.'
    } elseif ($arch -ne 'AMD64') {
        Write-Failure "Arquitectura no soportada: $arch"
        Write-Info 'Breuk Agent se publica hoy solo para Windows x86_64.'
        return
    }

    # Breuk Agent es una app de escritorio (Wails): usa el runtime de WebView2
    # del sistema. Windows 11 lo trae preinstalado y Windows 10 lo recibe con
    # Edge, pero una imagen recortada puede no tenerlo — y sin él el binario
    # se descarga bien y crashea al primer arranque. Mismo criterio que la
    # verificacion de WebKitGTK en install.sh: si no se puede comprobar, se
    # avisa y se sigue; un falso negativo no debe negar la instalacion.
    $webview2Guid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
    $webview2Keys = @(
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$webview2Guid",
        "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$webview2Guid",
        "HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$webview2Guid"
    )
    $hasWebView2 = $false
    foreach ($key in $webview2Keys) {
        if (Test-Path $key) {
            $version = (Get-ItemProperty -Path $key -Name 'pv' -ErrorAction SilentlyContinue).pv
            if ($version) { $hasWebView2 = $true; break }
        }
    }
    if (-not $hasWebView2) {
        Write-Warn 'No se detecto el runtime de WebView2, necesario para ejecutar Breuk Agent.'
        Write-Info 'Si al arrancar no se abre la ventana, instalalo desde:'
        Write-Info '  https://developer.microsoft.com/microsoft-edge/webview2/'
    }

    # Resolucion de version: /releases/latest ignora las prereleases, asi que
    # se toma la mas reciente del listado completo (mismo criterio que
    # install.sh). $env:VERSION la fija a mano.
    $requestedVersion = $env:VERSION
    if ([string]::IsNullOrWhiteSpace($requestedVersion)) {
        try {
            $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases?per_page=1" -Headers @{ 'User-Agent' = 'breuk-installer' }
        } catch {
            Write-Failure "No se pudo consultar la ultima version: $($_.Exception.Message)"
            return
        }
        if (-not $releases) {
            Write-Failure 'No se pudo obtener informacion de version'
            return
        }
        # -Uri con ?per_page=1 devuelve un array de un elemento; PowerShell lo
        # colapsa a objeto cuando es uno solo, asi que hay que contemplar los
        # dos casos.
        $tag = if ($releases -is [array]) { $releases[0].tag_name } else { $releases.tag_name }
        $specificVersion = $tag -replace '^v', ''
    } else {
        $specificVersion = $requestedVersion -replace '^v', ''
    }

    # Atajo "ya instalado": la version sale por el flag --version, con formato
    # "0.1.21 (skills 2026-07-27)".
    $existing = Get-Command $app -ErrorAction SilentlyContinue
    if ($existing) {
        $installedVersion = $null
        try {
            $installedVersion = (& $app --version 2>$null | Select-Object -First 1).Split(' ')[0]
        } catch {
            $installedVersion = $null
        }
        if ($installedVersion -eq $specificVersion) {
            Write-Info "La version $specificVersion ya esta instalada"
            return
        } elseif ($installedVersion) {
            Write-Info "Version instalada: $installedVersion."
        }
    }

    $filename = "$app-windows-x86_64.zip"
    $url = "https://github.com/$repo/releases/download/v$specificVersion/$filename"
    $checksumsUrl = "https://github.com/$repo/releases/download/v$specificVersion/checksums.txt"

    $tmpdir = Join-Path ([System.IO.Path]::GetTempPath()) ("breuk-install-" + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmpdir -Force | Out-Null

    try {
        Write-Info "Descargando breuk version: $specificVersion ..."
        $zipPath = Join-Path $tmpdir $filename
        $checksumsPath = Join-Path $tmpdir 'checksums.txt'
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
            Invoke-WebRequest -Uri $checksumsUrl -OutFile $checksumsPath -UseBasicParsing
        } catch {
            Write-Failure "Fallo la descarga: $($_.Exception.Message)"
            Write-Info "URL: $url"
            return
        }

        # checksums.txt viene en formato sha256sum: "<hash>  <archivo>".
        $expected = $null
        foreach ($line in Get-Content $checksumsPath) {
            $fields = $line -split '\s+', 2
            if ($fields.Count -eq 2 -and $fields[1].Trim() -eq $filename) {
                $expected = $fields[0].Trim()
                break
            }
        }
        if (-not $expected) {
            Write-Failure "No se encontro el checksum de $filename en checksums.txt"
            return
        }

        $actual = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash
        if ($actual -ne $expected.ToUpperInvariant()) {
            Write-Failure "Fallo la verificacion de checksum de $filename"
            Write-Failure "  esperado: $expected"
            Write-Failure "  obtenido: $actual"
            return
        }
        Write-Info 'Checksum OK'

        $extractDir = Join-Path $tmpdir 'extracted'
        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
        $binary = Join-Path $extractDir 'breuk.exe'
        if (-not (Test-Path $binary)) {
            Write-Failure 'El archive no contiene breuk.exe'
            return
        }

        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        try {
            Move-Item -Path $binary -Destination (Join-Path $installDir 'breuk.exe') -Force
        } catch {
            # Windows bloquea el reemplazo de un .exe en ejecucion, a
            # diferencia de Linux/macOS — es el modo de fallo mas probable al
            # actualizar, y el mensaje del sistema no lo explica.
            Write-Failure "No se pudo escribir en $installDir : $($_.Exception.Message)"
            Write-Info 'Si Breuk Agent esta abierto, cerralo y volve a ejecutar el instalador.'
            return
        }
    } finally {
        Remove-Item -Path $tmpdir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # PATH del usuario (persistente) + la sesion en curso, para que `breuk`
    # funcione sin reabrir la consola.
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) { $userPath = '' }
    # El @( ) no es decorativo: cuando el filtro no encuentra nada —el caso de
    # toda primera instalacion— el pipeline devuelve $null, y bajo
    # Set-StrictMode pedirle .Count a $null aborta el instalador justo despues
    # de haber copiado el binario, dejandolo fuera del PATH.
    $alreadyInPath = @($userPath -split ';' | Where-Object { $_.TrimEnd('\') -eq $installDir.TrimEnd('\') }).Count -gt 0
    if (-not $alreadyInPath) {
        $newPath = if ($userPath.TrimEnd(';')) { $userPath.TrimEnd(';') + ';' + $installDir } else { $installDir }
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Info "Se agrego breuk al PATH en $installDir"
    }
    $sessionPath = $env:Path
    if (-not $sessionPath) { $sessionPath = '' }
    $inSessionPath = @($sessionPath -split ';' | Where-Object { $_.TrimEnd('\') -eq $installDir.TrimEnd('\') }).Count -gt 0
    if (-not $inSessionPath) {
        $env:Path = ($sessionPath.TrimEnd(';') + ';' + $installDir).TrimStart(';')
    }

    Write-Host ''
    Write-Info "Breuk Agent $specificVersion instalado en $installDir"
    Write-Host ''
    Write-Host '  Autoriza esta terminal:  ' -NoNewline; Write-Host 'breuk login' -ForegroundColor Yellow
    Write-Host '  Abri la aplicacion:      ' -NoNewline; Write-Host 'breuk' -ForegroundColor Yellow
    Write-Host ''
}

Install-BreukAgent
