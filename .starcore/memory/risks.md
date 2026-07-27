# Risk Register — STARCORE Platform

> **Kanonický** risk register. `reports/*.md` jsou historické archivy — tento soubor je zdrojem pravdy.
> **Poslední aktualizace:** 2026-07-27

## Legenda

| Stav | Popis |
|------|-------|
| OPEN | Aktivní, nevyřešené |
| MITIGATED | Zmírněno, monitoring |
| CLOSED | Opraveno a ověřeno |
| DEFERRED | Záměrně odloženo s ADR |
| ACCEPTED | Přijato jako known risk s dokumentací |

| Závažnost | Kritéria |
|-----------|---------|
| CRITICAL | Bezpečnostní dopad nebo ztráta dat |
| HIGH | Funkční dopad nebo CI blokátor |
| MEDIUM | Provozní riziko, časem eskaluje |
| LOW | Technický dluh, malý dopad |

---

## CRITICAL / HIGH

### R-001 — GitHub Actions SHA pinning
- **Stav:** CLOSED
- **Závažnost:** HIGH
- **Uzavřeno:** 2026-07-27 (commit `c0d2b38`)
- **Soubory:** `.github/workflows/ci.yml`, `codeql.yml`, `docker-publish.yml`, `release.yml`, `security-nightly.yml`, `dependabot-auto-merge.yml`, `jekyll-gh-pages.yml`
- **Oprava:** 22 mutable referencí pinned na immutable commit SHA ve všech 7 workflow souborech; verze zachována jako inline komentář (`@SHA # vX`)

---

## MEDIUM

### R-007 — jekyll-gh-pages.yml (inactive workflow)
- **Stav:** OPEN / ACCEPTED pending operator decision
- **Závažnost:** MEDIUM
- **Soubor:** `.github/workflows/jekyll-gh-pages.yml`
- **Problém:** Workflow na GitHub Pages build pomocí Jekyll — projekt nepoužívá Jekyll (používá MkDocs). Workflow je neaktivní ale zavádí zbytečnou attack surface.
- **Návrh opravy:** Smazat soubor nebo zakázat
- **Blokátor:** Vyžaduje rozhodnutí operátora (mohl by být záměrně ponechán)
- **Priorita:** P2

### R-008 — Dependabot auto-merge scope
- **Stav:** OPEN / ACCEPTED pending operator decision
- **Závažnost:** MEDIUM
- **Soubor:** `.github/workflows/dependabot-auto-merge.yml`
- **Problém:** Auto-merge všech Dependabot patch PR bez code review — patch update může obsahovat breaking change nebo supply chain útok
- **Návrh opravy:** Omezit na `pip` ekosystém a/nebo přidat label gating
- **Blokátor:** Preference týmu / operátora
- **Priorita:** P2

### R-010 — SBOM/provenance attestations
- **Stav:** OPEN
- **Závažnost:** MEDIUM
- **Problém:** Docker image neobsahuje SBOM ani sigstore/cosign attestaci — nelze ověřit supply chain při deployi
- **Návrh opravy:** Přidat `syft` pro SBOM generování a `cosign` pro signing do `docker-publish.yml`
- **Priorita:** P2
- **Odhad práce:** 2-4 hodiny

---

## LOW

### R-012 — assert guards v provider kódu
- **Stav:** OPEN
- **Závažnost:** LOW
- **Soubory:** `packages/providers/proxmox/provider.py`, `packages/providers/docker/provider.py`
- **Problém:** 11 `assert` statementů v produkčním kódu — v Python s `-O` flag jsou vynechány → RuntimeError místo AssertionError
- **Návrh opravy:** Každý `assert condition, msg` → `if not condition: raise ValueError(msg)`
- **Priorita:** P2

### R-016 — STARCORE_POSTGRES_PASSWORD dokumentace
- **Stav:** OPEN
- **Závažnost:** LOW
- **Problém:** Proměnná `STARCORE_POSTGRES_PASSWORD` se objevuje v `docker-compose.yml` ale není dokumentována v CLAUDE.md konfig tabulce
- **Návrh opravy:** Přidat řádek do konfig tabulky, nebo potvrdit že proměnná je jen pro docker-compose a není v Settings
- **Priorita:** P3

### R-018 — Packaging completeness
- **Stav:** OPEN
- **Závažnost:** LOW
- **Problém:** `migrations/`, `alembic.ini`, `plugins/` nejsou explicitně zahrnuty ve wheel include patterns v `pyproject.toml`
- **Návrh opravy:** Přidat do `[tool.hatch.build.targets.wheel]` nebo ověřit že `uv build` je zahrnuje správně
- **Priorita:** P3

---

## CLOSED (opraveno)

### R-005 — WAIT_AND_MARK/IGNORE coroutine-reuse RuntimeError
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `134a939`)
- **Problém:** `execute_with_timeout()` re-awaited spent coroutine po `asyncio.wait_for` cancellation → `RuntimeError: cannot reuse already awaited coroutine`
- **Oprava:** `asyncio.create_task()` + `asyncio.shield()` pattern; testy přepsány z monkeypatching na real async timing

### R-006 — ruff format gate chybělo v CI
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `c4775f6`)
- **Oprava:** Přidán krok `ruff format --check .` do `ci.yml`; reformatováno 8 souborů

### R-009 — Dead code v Proxmox provider
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `6aa41c0`)
- **Oprava:** Smazán permanentně nedosažitelný `if resource_kind == "lxc"` blok

### R-002 — Phantom env vars v dokumentaci
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `801ffb4`)
- **Oprava:** Odstraněny `STARCORE_AGENT_MODE`, `STARCORE_DEBUG_PROVIDER` a podobné z `docs/ENHANCEMENTS.md`

### R-003 — Phantom test paths
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `801ffb4`)
- **Oprava:** Odstraněny reference na neexistující test soubory

### R-025 — codeql.yml checkout @v4 (zastaralý)
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `260de1b`)
- **Oprava:** `@v4` → `@v7`

### R-026 — nats:latest v docker-compose.yml
- **Stav:** CLOSED
- **Opraveno:** 2026-07-27 (commit `260de1b`)
- **Oprava:** `nats:latest` → `nats:2.10`

---

## DEFERRED (záměrně odloženo)

### R-004 — Task timeout integrace do Scheduler/BlueprintExecutor
- **Stav:** DEFERRED
- **Dokumentace:** ADR-016
- **Důvod:** Per-task timeout konfigurace neexistuje v blueprint schema; global timeout by byl příliš hrubý pro smíšené workloady (Proxmox clone vs. container start)
- **Podmínky pro revisit:** Blueprint schema dostane `timeout_seconds` field; nebo production incident způsobený hung taskiem
