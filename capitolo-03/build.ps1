# Script di build del Capitolo 3 (PDF) — richiede Pandoc e MiKTeX (xelatex).
param(
    [string]$Pandoc = "C:\Users\Andrea\AppData\Local\Pandoc\pandoc.exe",
    [string]$XeLaTeX = "C:\Users\Andrea\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sezioni = Join-Path $root "sezioni"
$outMd = Join-Path $root "capitolo-03.md"
$outTex = Join-Path $root "capitolo-03.tex"
$outPdf = Join-Path $root "capitolo-03.pdf"

# 1. Concatena le sezioni in ordine alfabetico (prefissi numerici 00, 01, ...).
$files = Get-ChildItem $sezioni -Filter "*.md" | Sort-Object Name
$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
    [void]$sb.AppendLine((Get-Content $f.FullName -Raw -Encoding UTF8))
    [void]$sb.AppendLine("")
}
Set-Content -Path $outMd -Value $sb.ToString() -Encoding UTF8
Write-Host "Sezioni combinate: $($files.Count) file -> $outMd"

# 2. Pandoc: Markdown -> LaTeX (book class, TOC, A4).
Push-Location $root
& $Pandoc $outMd -o $outTex --standalone `
    --pdf-engine=$XeLaTeX `
    --toc --toc-depth=2 `
    -V documentclass=book `
    -V fontsize=10pt `
    -V "geometry:papersize={6in,9in},inner=0.75in,outer=0.5in,top=0.7in,bottom=0.7in" `
    -V lang=it `
    -V colorlinks=true `
    -V linkcolor=blue `
    -V urlcolor=blue `
    --syntax-highlighting=tango `
    -H (Join-Path $root "header.tex")

if ($LASTEXITCODE -ne 0) { throw "Pandoc fallito con codice $LASTEXITCODE" }
Pop-Location

# 3. xelatex (due passate per TOC e riferimenti).
Push-Location $root
try {
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "capitolo-03.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Prima passata xelatex fallita" }
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "capitolo-03.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Seconda passata xelatex fallita" }
} finally {
    Pop-Location
}

# 4. Legge il numero di pagine dal log.
$log = Join-Path $root "capitolo-03.log"
if (Test-Path $log) {
    $match = Select-String -Path $log -Pattern "Output written on .*\((\d+) page" | Select-Object -Last 1
    if ($match -and $match.Matches[0].Groups.Count -gt 1) {
        Write-Host "PDF generato: $outPdf ($($match.Matches[0].Groups[1].Value) pagine)"
    } else {
        Write-Host "PDF generato: $outPdf"
    }
}


