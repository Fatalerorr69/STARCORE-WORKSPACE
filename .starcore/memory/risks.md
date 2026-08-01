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
- **Stav:** CLOSED
- **Závažnost:** MEDIUM
- **Uzavřeno:** 2026-08-01
- **Oprava:** Přidány 4 kroky do `docker-publish.yml`: `sigstore/cosign-installer@v3.10.1`, `anchore/sbom-action@v0.24.0` (SPDX-JSON), `cosign sign` (keyless OIDC), `cosign attest` (SBOM připojen k image digestu); přidána oprávnění `id-token: write` + `attestations: write`

---

## LOW

### R-012 — assert guards v provider kódu
- **Stav:** CLOSED
- **Závažnost:** LOW
- **Uzavřeno:** 2026-07-27
- **Oprava:** 11 `assert self._client is not None` → `if self._client is None: raise RuntimeError("... not connected")` v proxmox/provider.py (9×) a docker/provider.py (2×); 11 nových testů přidáno, 580/580 testů, 100% coverage

### R-016 — STARCORE_POSTGRES_PASSWORD dokumentace
- **Stav:** CLOSED
- **Závažnost:** LOW
- **Uzavřeno:** 2026-07-27
- **Oprava:** Přidán řádek do CLAUDE.md config tabulky s poznámkou "docker-compose only" — proměnná není v Settings

### R-018 — Packaging completeness
- **Stav:** CLOSED
- **Závažnost:** LOW
- **Uzavřeno:** 2026-07-27
- **Oprava:** `plugins` přidán do `packages`; `migrations` a `alembic.ini` přidány do `[tool.hatch.build.targets.wheel.force-include]`; wheel entries: 58 → 65

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
