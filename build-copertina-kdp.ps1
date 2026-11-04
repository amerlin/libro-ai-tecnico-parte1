# Genera la copertina completa per Amazon KDP (fronte + dorso + retro con bleed).
# Il dorso è calcolato dal numero di pagine del volume e dal tipo di carta.
param(
    [string]$XeLaTeX = "C:\Users\Andrea\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe",
    [string]$VolumePdf = "libro-ai-tecnico.pdf",
    [double]$SpinePerPage = 0.002252  # pollici per pagina, inchiostro nero su carta bianca KDP
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pdf = Join-Path $root $VolumePdf
if (-not (Test-Path $pdf)) { throw "Volume non trovato: $pdf" }

# Numero di pagine dal PDF.
$info = & pdfinfo $pdf 2>&1
$pages = 0
foreach ($line in $info) {
    if ($line -match '^Pages:\s+(\d+)') { $pages = [int]$Matches[1]; break }
}
if ($pages -eq 0) { throw "Impossibile leggere il numero di pagine da $pdf" }

# Dorso in centimetri: pagine x pollici/pagina x 2,54.
$spineCm = [math]::Round($pages * $SpinePerPage * 2.54, 4)
$spineTex = Join-Path $root "capitolo-05\spine-kdp.tex"
"\def\spinewidthcm{$spineCm cm}" | Set-Content -Path $spineTex -Encoding ASCII
Write-Host "Pagine: $pages -> dorso: $spineCm cm (carta bianca, inchiostro nero)"

Push-Location (Join-Path $root "capitolo-05")
try {
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "copertina-kdp.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Prima passata xelatex fallita" }
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "copertina-kdp.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Seconda passata xelatex fallita" }
} finally {
    Pop-Location
}

$out = Join-Path $root "capitolo-05\copertina-kdp.pdf"
if (Test-Path $out) {
    $pdfInfo = & pdfinfo $out 2>&1
    $size = ($pdfInfo | Select-String '^Page size:').Line
    Write-Host "Copertina generata: $out"
    Write-Host "$size"
} else {
    throw "Copertina non generata"
}
