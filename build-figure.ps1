# Compila le figure TikZ (capitolo-*/figure/*.tex) in PDF vettoriali, pronti per l'inclusione nei capitoli.
param(
    [string]$XeLaTeX = "C:\Users\Andrea\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sources = Get-ChildItem $root -Recurse -Filter "*.tex" | Where-Object { $_.Directory.Name -eq "figure" } | Sort-Object FullName

if ($sources.Count -eq 0) { throw "Nessun file .tex trovato nelle cartelle figure/" }

foreach ($tex in $sources) {
    Push-Location $tex.DirectoryName
    try {
        & $XeLaTeX -interaction=nonstopmode -halt-on-error $tex.Name | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Compilazione di $($tex.Name) fallita (vedi $($tex.BaseName).log)" }
        $pdf = Join-Path $tex.DirectoryName "$($tex.BaseName).pdf"
        Write-Host "Figura generata: $pdf"
        Remove-Item (Join-Path $tex.DirectoryName "$($tex.BaseName).aux"), (Join-Path $tex.DirectoryName "$($tex.BaseName).log") -ErrorAction SilentlyContinue
    } finally {
        Pop-Location
    }
}

Write-Host "Figure compilate: $($sources.Count)"
