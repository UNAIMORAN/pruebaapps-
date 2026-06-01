<#
.SYNOPSIS
  Cambia el esquema de URL usado por el login con Google (OAuth) en todo el proyecto.

.DESCRIPTION
  La herramienta `rename` (pub.dev/packages/rename) cambia el nombre y el bundle/package
  ID de la app, pero NO toca el esquema de URL personalizado que usa el login con Google.
  Este script lo reemplaza en los 4 sitios donde aparece:
    - lib/pages/login_page.dart        (constante _oauthRedirect)
    - lib/scheme_registrar_io.dart     (constante _scheme, registro en Windows)
    - android/app/src/main/AndroidManifest.xml  (intent-filter)
    - ios/Runner/Info.plist            (CFBundleURLSchemes)

  Lo normal es que el esquema coincida con el nuevo bundle/package ID de la app.

.PARAMETER NuevoEsquema
  El nuevo esquema (sin "://"), p.ej. com.miempresa.miapp

.EXAMPLE
  ./tools/cambiar_esquema_oauth.ps1 -NuevoEsquema com.miempresa.miapp
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$NuevoEsquema
)

$ErrorActionPreference = 'Stop'

# Esquema actual en la plantilla.
$Viejo = 'com.example.pruebaapps'

# Raíz del proyecto = carpeta padre de este script (tools/).
$raiz = Split-Path -Parent $PSScriptRoot

$archivos = @(
  'lib/pages/login_page.dart',
  'lib/scheme_registrar_io.dart',
  'android/app/src/main/AndroidManifest.xml',
  'ios/Runner/Info.plist'
)

if ($NuevoEsquema -eq $Viejo) {
  Write-Host "El nuevo esquema es igual al actual ($Viejo). Nada que hacer." -ForegroundColor Yellow
  return
}

$utf8SinBom = New-Object System.Text.UTF8Encoding($false)
$totalCambios = 0

foreach ($rel in $archivos) {
  $ruta = Join-Path $raiz $rel
  if (-not (Test-Path $ruta)) {
    Write-Host "AVISO: no encontrado $rel (se omite)" -ForegroundColor Yellow
    continue
  }
  $contenido = [System.IO.File]::ReadAllText($ruta)
  $apariciones = ([regex]::Matches($contenido, [regex]::Escape($Viejo))).Count
  if ($apariciones -gt 0) {
    $nuevo = $contenido.Replace($Viejo, $NuevoEsquema)
    [System.IO.File]::WriteAllText($ruta, $nuevo, $utf8SinBom)
    Write-Host "OK  $rel  ($apariciones reemplazo/s)" -ForegroundColor Green
    $totalCambios += $apariciones
  } else {
    Write-Host "--  $rel  (sin coincidencias)" -ForegroundColor DarkGray
  }
}

Write-Host ""
Write-Host "Hecho: $totalCambios reemplazo(s). Esquema '$Viejo' -> '$NuevoEsquema'." -ForegroundColor Cyan
Write-Host "Recuerda actualizar tambien la 'Redirect URL' en Supabase a:" -ForegroundColor Cyan
Write-Host "  $NuevoEsquema`://login-callback/" -ForegroundColor White
