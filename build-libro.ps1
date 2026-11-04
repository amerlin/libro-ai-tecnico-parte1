# Script di build del volume unico (PDF) — richiede Pandoc e MiKTeX (xelatex).
# Concatena tutti i capitoli in un solo documento, con indice e numerazione delle pagine unificati.
param(
    [string]$Pandoc = "C:\Users\Andrea\AppData\Local\Pandoc\pandoc.exe",
    [string]$XeLaTeX = "C:\Users\Andrea\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe",
    [string]$OutFile = "libro-ai-tecnico"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outMd = Join-Path $root "$OutFile.md"
$outTex = Join-Path $root "$OutFile.tex"
$outPdf = Join-Path $root "$OutFile.pdf"

$capitoli = Get-ChildItem $root -Directory -Filter "capitolo-*" | Sort-Object Name
if ($capitoli.Count -eq 0) { throw "Nessuna cartella capitolo-* trovata in $root" }

# 1. Frontespizio del volume + sezioni di tutti i capitoli, in ordine.
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("---")
[void]$sb.AppendLine('title: "Quaderno AI"')
[void]$sb.AppendLine('subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"')
[void]$sb.AppendLine('author: "Andrea Merlin"')
[void]$sb.AppendLine('date: "Numero 1 - Novembre 2026"')
[void]$sb.AppendLine("lang: it")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

$inclusi = 0
foreach ($cap in $capitoli) {
    $sezioni = Join-Path $cap.FullName "sezioni"
    if (-not (Test-Path $sezioni)) {
        Write-Warning "Salto $($cap.Name): manca la cartella sezioni/"
        continue
    }
    $files = Get-ChildItem $sezioni -Filter "*.md" | Sort-Object Name
    if ($files.Count -eq 0) {
        Write-Warning "Salto $($cap.Name): nessun file .md in sezioni/"
        continue
    }
    Write-Host "Aggiungo $($cap.Name): $($files.Count) sezioni"
    foreach ($f in $files) {
        $text = Get-Content $f.FullName -Raw -Encoding UTF8
        # Il blocco YAML del frontespizio di capitolo non serve: i metadati del volume sono quelli sopra.
        $text = $text -replace '(?s)^\uFEFF?---\r?\n.*?\r?\n---\r?\n', ''
        # Nel volume unico i percorsi delle figure sono relativi alla radice del repository.
        $text = $text -replace '\]\(figure/', "]($($cap.Name)/figure/"
        [void]$sb.AppendLine($text.TrimEnd())
        [void]$sb.AppendLine("")
    }
    $inclusi++
}

Set-Content -Path $outMd -Value $sb.ToString() -Encoding UTF8
Write-Host "Volume combinato: $inclusi capitoli -> $outMd"

# Verifica che il PDF di destinazione non sia aperto in un altro programma (xelatex fallirebbe con un errore poco chiaro).
if (Test-Path $outPdf) {
    try {
        $fs = [System.IO.File]::Open($outPdf, 'Open', 'ReadWrite', 'None')
        $fs.Close()
    } catch {
        throw "Impossibile sovrascrivere $outPdf : il file è aperto in un altro programma. Chiudilo e riprova."
    }
}

# 2. Preambolo LaTeX aggiuntivo: quello comune del primo capitolo (identico in ogni capitolo).
$header = Join-Path $root "header.tex"
if (-not (Test-Path $header)) {
    $header = Join-Path $capitoli[0].FullName "header.tex"
}
if (-not (Test-Path $header)) { throw "header.tex non trovato" }

# 3. Genera anche la copertina autonoma, usando lo stesso sorgente incluso nel volume.
Push-Location (Join-Path $root "capitolo-05")
try {
    & $XeLaTeX -jobname=copertina -interaction=nonstopmode -halt-on-error "copertina-standalone.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Compilazione della copertina fallita" }
} finally {
    Pop-Location
}

# 4. Pandoc: Markdown -> LaTeX (book class, TOC, A4). Gli H1 diventano \chapter.
Push-Location $root
& $Pandoc $outMd -o $outTex --standalone `
    --pdf-engine=$XeLaTeX `
    --toc --toc-depth=2 `
    --top-level-division=chapter `
    -V documentclass=book `
    -V fontsize=10pt `
    -V "geometry:papersize={6in,9in},inner=0.75in,outer=0.5in,top=0.7in,bottom=0.7in" `
    -V lang=it `
    -V colorlinks=true `
    -V linkcolor=blue `
    -V urlcolor=blue `
    --syntax-highlighting=tango `
    -H $header `
    -H (Join-Path $root "capitolo-05\header-copertina.tex")

if ($LASTEXITCODE -ne 0) { throw "Pandoc fallito con codice $LASTEXITCODE" }
Pop-Location

# 5. xelatex (due passate per TOC e riferimenti).
Push-Location $root
try {
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "$OutFile.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Prima passata xelatex fallita" }
    & $XeLaTeX -interaction=nonstopmode -halt-on-error "$OutFile.tex" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Seconda passata xelatex fallita" }
} finally {
    Pop-Location
}

# 6. Legge il numero di pagine dal log.
$log = Join-Path $root "$OutFile.log"
if (Test-Path $log) {
    $match = Select-String -Path $log -Pattern "Output written on .*\((\d+) page" | Select-Object -Last 1
    if ($match -and $match.Matches[0].Groups.Count -gt 1) {
        Write-Host "PDF generato: $outPdf ($($match.Matches[0].Groups[1].Value) pagine)"
    } else {
        Write-Host "PDF generato: $outPdf"
    }
}
