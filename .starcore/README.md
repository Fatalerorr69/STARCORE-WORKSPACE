# .starcore/ — Perzistentní paměť projektu

Tento adresář je **cross-session state layer** pro STARCORE Autonomous Engineering Agent.
Slouží jako sdílená paměť mezi Claude Code sezeními — nové sezení zde najde vše potřebné
pro okamžité převzetí práce bez re-derivace kontextu.

## Struktura

```
.starcore/
  README.md                    — tento soubor; přehled struktury
  memory/
    risks.md                   — kanonický risk register
    user_preferences.md        — preference uživatele a pravidla pro approval
    project_snapshot.md        — klíčová fakta pro cold start
    architecture.md            — referenční přehled architektury
    decisions.md               — pracovní rozhodnutí (pre-ADR)
    known_issues.md            — aktivní známé problémy
    completed_work.md          — záznam dokončené práce
    pending_work.md            — zbývající práce s prioritami
  sessions/
    current.md                 — aktivní session ledger
    archive/                   — archiv ukončených sezení
  prompts/
    registry.yaml              — katalog registrovaných promptů (PROM-xxx)
    master/                    — master provozní prompty
    audits/                    — audit prompty
    implementation/            — implementační prompty
    recovery/                  — recovery prompty
  reports/
    latest/                    — nejnovější vygenerované reporty
    archive/                   — archiv reportů
  state/
    regression_baseline.json   — sentinel baseline (testy, coverage, vulns)
    release.md                 — stav release readiness
```

## Pravidla pro práci s tímto adresářem

1. **Nikdy neskladuj secrets/credentials** — ani redacted ani placeholder formy
2. **Udržuj `sessions/current.md` aktuální** — na konci každého sezení archivuj do `sessions/archive/`
3. **`state/regression_baseline.json` aktualizuj** po každém úspěšném průchodu CI gates
4. **`memory/pending_work.md` aktualizuj** při každé změně scope (přidání/dokončení práce)
5. **`memory/risks.md`** je kanonický risk register — `reports/*.md` jsou historické archivy

## Cold-start protokol (pro nová sezení)

1. Přečti `memory/project_snapshot.md` — klíčová fakta
2. Přečti `sessions/current.md` — kde předchozí sezení skončilo
3. Přečti `memory/pending_work.md` — co zbývá udělat
4. Přečti `memory/risks.md` — aktivní rizika
5. Ověř git stav (`git status`, `git log --oneline -5`)
6. Spusť smoke-test (`uv run pytest -q --tb=no 2>&1 | tail -3`)
7. Teprve pak začni pracovat

## Odkaz v CLAUDE.md

Viz sekci "Persistent project memory" v kořenovém CLAUDE.md.
