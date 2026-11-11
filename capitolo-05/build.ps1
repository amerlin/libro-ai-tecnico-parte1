# Script di build del Capitolo 5 (PDF) — richiede Pandoc e MiKTeX (xelatex).
param(
    [string]$Pandoc = "C:\Users\Andrea\AppData\Local\Pandoc\pandoc.exe",
    [string]$XeLaTeX = "C:\Users\Andrea\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sezioni = Join-Path $root "sezioni"
$outMd = Join-Path $root "capitolo-05.md"
$outTex = Join-Path $root "capitolo-05.tex"
$outPdf = Join-Path $root "capitolo-05.pdf"

$files = Get-ChildItem $sezioni -Filter "*.md" | Sort-Object Name
if (-not $files) { throw "Nessuna sezione Markdown trovata in $sezioni" }

$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
    [void]$sb.AppendLine((Get-Content $f.FullName -Raw -Encoding UTF8))
    [void]$sb.AppendLine("")
}
Set-Content -Path $outMd -Value $sb.ToString() -Encoding UTF8
Write-Host "Sezioni combinate: $($files.Count) file -> $outMd"

Push-Location $root
try {
    & $Pandoc $outMd -o $outTex --standalone `
        --pdf-engine=$XeLaTeX `
        --toc --toc-depth=2 `
        -V documentclass=book `
        -V fontsize=11pt `
        -V "geometry:papersize={6in,9in},inner=0.75in,outer=0.5in,top=0.7in,bottom=0.7in" `
        -V lang=it `
        -V colorlinks=true `
        -V linkcolor=blue `
        -V urlcolor=blue `
        --syntax-highlighting=tango `
        -H (Join-Path $root "header.tex")
    if ($LASTEXITCODE -ne 0) { throw "Pandoc fallito con codice $LASTEXITCODE" }

    & $XeLaTeX -interaction=nonstopmode -halt-on-error "capitolo-05.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Prima passata xelatex fallita" }
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "capitolo-05.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Seconda passata xelatex fallita" }
}
finally {
    Pop-Location
}

$log = Join-Path $root "capitolo-05.log"
if (Test-Path $log) {
    $match = Select-String -Path $log -Pattern "Output written on .*\((\d+) page" | Select-Object -Last 1
    if ($match -and $match.Matches[0].Groups.Count -gt 1) {
        $pages = [int]$match.Matches[0].Groups[1].Value
        Write-Host "PDF generato: $outPdf ($pages pagine)"
        if ($pages -lt 50) { Write-Warning "Il PDF ha meno di 50 pagine; ampliare il contenuto prima della pubblicazione." }
    } else {
        Write-Host "PDF generato: $outPdf"
    }
}
