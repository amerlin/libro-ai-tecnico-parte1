# Quaderno AI

## Concetti, strumenti e percorsi pratici per lo sviluppo software con AI

Quaderno AI è una serie di pubblicazioni tecniche in italiano. Questo è il **Numero 1 - Novembre 2026**: raccoglie concetti, strumenti e percorsi pratici per lo sviluppo software con AI, con esempi basati sull'ecosistema .NET 10. Ogni capitolo è autonomo e si apre con un frontespizio, un abstract e gli obiettivi di apprendimento.

## Capitoli

| # | Titolo | Argomenti | PDF |
|---|--------|-----------|-----|
| 1 | **Model Context Protocol: fondamenti e implementazione di un MCP Server in .NET 10** | Perché MCP, architettura e primitivi (tool, risorse, prompt), JSON-RPC, trasporti `stdio` e HTTP, lifecycle, confronto con REST, ecosistema .NET, primo server, client .NET, test con MCP Inspector, sicurezza e troubleshooting | [capitolo-01.pdf](capitolo-01/capitolo-01.pdf) |
| 2 | **Un MCP Server con Entity Framework Core: dati, query e primitivi avanzati** | Dominio catalogo prodotti, `DbContext` e modelli, connessione SQLite, migrazioni con `dotnet ef`, pattern `IDbContextFactory`, tool di lettura e scrittura, server `stdio` e HTTP, il primitivo `Progress` e testing con MCP Inspector | [capitolo-02.pdf](capitolo-02/capitolo-02.pdf) |
| 3 | **GitHub Spec Kit: sviluppo guidato dalle specifiche con esempi in C#** | Spec-driven development, installazione del CLI `specify`, struttura del progetto, workflow completo (constitution, specify, clarify, plan, checklist, tasks, analyze, implement, converge), esempio end-to-end con Minimal API in C#, integrazione con VS Code/Copilot, CI/CD, bugfix, assessment e confronti con approcci alternativi | [capitolo-03.pdf](capitolo-03/capitolo-03.pdf) |
| 4 | **Istruzioni, skill, agenti e plugin: estendere un agente di codifica** | I quattro livelli di personalizzazione, istruzioni con attivazione per pattern, standard Agent Skills, agenti con strumenti limitati e handoff, plugin (Agent Plugins 1.0 e formato Claude), mappa delle cartelle per Copilot, Claude Code, Cursor, Gemini CLI, Codex e DeepSeek, precedenze e conflitti, portabilità, verifica in CI, sicurezza e governance del team | [capitolo-04.pdf](capitolo-04/capitolo-04.pdf) |
| 5 | **Migrare a .NET da altri linguaggi e piattaforme** | Assessment, pianificazione incrementale, mappatura da PHP/Python/Node.js/Java, architettura ASP.NET Core, pipeline HTTP, DI e configurazione, dati con EF Core, sicurezza, testing, prestazioni, container e caso pratico | [capitolo-05.pdf](capitolo-05/capitolo-05.pdf) |

Il Capitolo 2 si appoggia ai concetti del Capitolo 1 (tool, trasporti, configurazione dei client); il Capitolo 4 riprende il Capitolo 3 nel caso delle skill di Spec Kit e il Capitolo 2 per il server MCP impacchettato in un plugin.

Oltre ai singoli PDF è disponibile il [volume unico](libro-ai-tecnico.pdf), con tutti i capitoli in un solo file, copertina, pagina autore e indice unificato.

## Struttura del repository

```text
libro-ai-tecnico/
|-- README.md
|-- build-figure.ps1            # compila le figure TikZ in PDF
|-- build-libro.ps1             # compila il volume unico
|-- libro-ai-tecnico.pdf        # volume unico generato (tutti i capitoli)
|-- capitolo-01/
|   |-- sezioni/
|   |-- figure/
|   `-- build.ps1
|-- capitolo-02/
|-- capitolo-03/
|-- capitolo-04/
`-- capitolo-05/
    |-- sezioni/
    |-- copertina-contenuto.tex # copertina del Numero 1
    |-- pagina-autore.tex       # pagina autore del volume unico
    |-- header-copertina.tex    # copertina inclusa nel volume
    `-- build.ps1
```

Le cartelle dei capitoli contengono:

- `sezioni/` — i sorgenti Markdown, uno per sezione;
- `build.ps1` — lo script che assembla le sezioni e genera il PDF;
- `capitolo-NN.pdf` — il PDF finale.

I Capitoli 1–4 includono anche `figure/`, con i sorgenti TikZ e i PDF vettoriali delle figure. Tutti i capitoli hanno un `header.tex` con impostazioni LaTeX aggiuntive.

## Requisiti per la build

- [Pandoc](https://pandoc.org/)
- [MiKTeX](https://miktex.org/) con `xelatex`

Gli script hanno percorsi predefiniti per Pandoc e MiKTeX nelle installazioni per-utente di Windows. Se hai installato i tool altrove, passa i percorsi come parametri:

```powershell
.\build.ps1 -Pandoc "C:\tools\pandoc\pandoc.exe" -XeLaTeX "C:\tools\miktex\xelatex.exe"
```

## Come generare un PDF

```powershell
.\build-figure.ps1      # solo se hai modificato i sorgenti TikZ in figure/
cd capitolo-02
.\build.ps1
```

`build.ps1` esegue quattro passaggi:

1. concatena le sezioni di `sezioni/` in ordine alfabetico (i prefissi numerici `00`, `01`, … determinano l'ordine di lettura);
2. converte il Markdown in LaTeX con Pandoc (classe `book`, formato 6″ × 9″ — 15,24 × 22,86 cm, corpo 10 pt, margini interni 0,75″ ed esterni 0,5″ con bordi superiore e inferiore da 0,7″, indice su due livelli, evidenziazione della sintassi stile `tango`, `header.tex` come preambolo);
3. compila due volte con `xelatex`, per generare indice e riferimenti;
4. stampa il numero di pagine del PDF generato.

Le figure sono già compilate in `capitolo-*/figure/*.pdf`: per rigenerarle dopo aver modificato un `.tex` esegui dalla radice `.\build-figure.ps1`, che compila tutte le figure dei capitoli.

## Volume unico (tutti i capitoli)

Dalla radice del repository:

```powershell
.\build-libro.ps1
```

Lo script genera [libro-ai-tecnico.pdf](libro-ai-tecnico.pdf) unendo **tutti** i capitoli trovati nelle cartelle `capitolo-*`, in ordine di nome. La copertina in formato 6″ × 9″ è inclusa come prima pagina; il sorgente è in `capitolo-05/copertina-contenuto.tex` e la versione autonoma è [copertina.pdf](capitolo-05/copertina.pdf). A ogni build entrambi i PDF vengono rigenerati dallo stesso sorgente. A differenza dei PDF di capitolo, il volume unico ha:

- un solo frontespizio e un **unico indice**, che elenca i capitoli e le loro sezioni;
- **numerazione delle pagine continua** (numeri romani per frontespizio e indice, arabici da 1 nel corpo);
- ogni capitolo inizia su una pagina nuova, senza pagine di titolo né indici intermedi (abstract, prerequisiti e convenzioni restano come sezioni del capitolo).

Come funziona: concatena i file `sezioni/*.md` di ogni capitolo, rimuovendo il blocco YAML del frontespizio di capitolo (i metadati del volume sono definiti all'inizio dello script), poi esegue Pandoc con `--top-level-division=chapter`, così ogni titolo `# Capitolo N` diventa un `\chapter`. Il preambolo LaTeX è quello di `header.tex` (usa `header.tex` nella radice se presente, altrimenti quello del primo capitolo).

Parametri disponibili:

```powershell
.\build-libro.ps1 -OutFile "libro-2026" -Pandoc "C:\tools\pandoc\pandoc.exe" -XeLaTeX "C:\tools\miktex\xelatex.exe"
```

I PDF dei singoli capitoli restano invariati e continuano a essere generati dai rispettivi `build.ps1`.

## Copertina per Amazon KDP

Per la pubblicazione su Amazon si usa una copertina completa (fronte + dorso + retro) con smarginatura di 0,125″ per lato:

```powershell
.\build-copertina-kdp.ps1
```

Lo script legge il numero di pagine da [libro-ai-tecnico.pdf](libro-ai-tecnico.pdf), calcola la larghezza del dorso (formula KDP per carta bianca: pagine × 0,002252 pollici) e compila [copertina-kdp.tex](capitolo-05/copertina-kdp.tex) producendo [copertina-kdp.pdf](capitolo-05/copertina-kdp.pdf). La misura del dorso è scritta in `capitolo-05/spine-kdp.tex`: se il numero di pagine cambia, basta rieseguire lo script. Il retro include lo spazio bianco per il codice a barre ISBN, aggiunto da Amazon in fase di pubblicazione.

## Convenzioni

- **Ordine delle sezioni.** Il nome del file è l'ordine: `00-frontespizio.md`, `01-…`, `02-…`. Per inserire una sezione senza rinumerare le successive si usa un suffisso alfabetico, come `21b-…` o `21c-…`.
- **Struttura di un capitolo.** Frontespizio con titolo e abstract, sezioni numerate (`2.4`, `2.4.1`, …) e, dove previsto, riepilogo finale e capitolo di troubleshooting.
- **Codice.** Tutti i frammenti sono compilati ed eseguiti con .NET 10; le versioni dei pacchetti sono indicate nel frontespizio di ciascun capitolo (per esempio `ModelContextProtocol` 2.3.0 ed Entity Framework Core 10.0.14 nel Capitolo 2).
- **Figure.** Ogni diagramma è una figura TikZ in `capitolo-NN/figure/`: il `.tex` è il sorgente, il `.pdf` è il vettoriale incluso nel capitolo con `![didascalia](figure/nome.pdf)`. Le figure usano la stessa classe di caratteri del libro (`\footnotesize`, 9 pt) e l'ancoraggio `[H]`, quindi restano nel punto in cui sono inserite. Per modificare un diagramma si edita il `.tex` e si riesegue `build-figure.ps1`.
- **Diagrammi testuali e tabelle.** Restano in Markdown (tabelle e blocchi ```` ```text ````) solo elenchi di comandi, output di esempio e tabelle. Nei blocchi di codice non si usano caratteri Unicode per gli alberi di directory (`├`, `─`): non esistono nei font monospazio usati da `xelatex` e verrebbero stampati come spazi vuoti.
- **Titoli che finiscono con `#`.** In un titolo Markdown un `#` finale viene interpretato da Pandoc come chiusura del titolo e non viene stampato (`## … in C#` diventa «in C»). Nei titoli va scritto `C\#`.
- **Artefatti di build.** Gli script producono anche `capitolo-NN.md`, `.tex`, `.aux`, `.log` e `.toc` (e, nella radice, `libro-ai-tecnico.*`): possono essere eliminati e vengono rigenerati a ogni esecuzione.
