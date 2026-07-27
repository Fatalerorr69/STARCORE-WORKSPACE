# Pending Work — STARCORE Platform

> Zbývající práce seřazená podle priority. Aktualizovat při každé změně scope.
> **Poslední aktualizace:** 2026-07-27

---

## P1 — Vyřešit brzy

### R-001: GitHub Actions SHA pinning
- **Popis:** 14 mutable version tags v 7 workflow souborech — supply chain riziko
- **Soubory:**
  - `.github/workflows/ci.yml` — `actions/checkout@v4`, `actions/setup-python@v5`, `docker/build-push-action@v5`, `docker/metadata-action@v5`, `docker/login-action@v3`, `actions/upload-artifact@v4`
  - `.github/workflows/codeql.yml` — `actions/checkout@v7` (aktualizováno, ale stále mutable tag)
  - `.github/workflows/docker-publish.yml` — docker actions
  - `.github/workflows/release.yml` — release actions
  - `.github/workflows/security-nightly.yml` — security actions
  - `.github/workflows/dependabot-auto-merge.yml` — gh-action-merge-dependabot
  - `.github/workflows/jekyll-gh-pages.yml` — Pages actions
- **Postup opravy:**
  ```bash
  # Pro každý action tag získat SHA:
  # gh api /repos/{owner}/{repo}/git/refs/tags/{tag} -> object.sha
  # pak nahradit @vX za @SHA # vX
  ```
- **Odhad:** 1-2 hodiny
- **Blokátor:** Žádný

### P2 — Deferrable

### R-007: Smazat nebo zakázat jekyll-gh-pages.yml
- **Blokátor:** Rozhodnutí operátora

### R-008: Omezit Dependabot auto-merge scope
- **Blokátor:** Preference týmu

### R-010: SBOM/provenance attestations
- **Odhad:** 2-4 hodiny

### R-012: assert guards → if/raise
- **Počet:** 11 assert statementů
- **Odhad:** 30 minut

### R-016: Dokumentovat STARCORE_POSTGRES_PASSWORD
- **Odhad:** 15 minut

### R-018: Packaging completeness (migrations/, alembic.ini, plugins/ ve wheel)
- **Odhad:** 30 minut

---

## P2 — From STARCORE-Next-Steps-Proposal.md (Deferred P2 items)

Tyto položky byly navrženy v předchozím auditu a záměrně odloženy na P2:

### 1. Request-scoped correlation ID logging rozšíření
- **Stav:** `packages/core/correlation.py` a `packages/core/request_id_middleware.py` existují (ADR-015)
- **Co zbývá:** Ověřit, že correlation ID skutečně prostupuje do provider log lines (nejen HTTP middleware)
- **Odhad:** 2-4 hodiny

### 2. Snapshot rollback dry-run diff
- **Popis:** Před `starcore snapshot rollback` vypsat diff (aktuální stav VM vs. stav ve snapshotu)
- **Entry points:** `apps/cli/main.py` → `snapshot_rollback()`, `_run_snapshot_action()`
- **Pozor:** Ověřit co Proxmox API skutečně vrací před slibováním diffu
- **Odhad:** půl dne

### 3. Provider concurrency policy ADR dokument
- **Stav:** ADR-013 existuje (no semaphore; trigger conditions defined)
- **Co zbývá:** Nic urgentního — revisit při přidání třetího providera

### 4. README "What's Planned, Not Built Yet" sekce
- **Stav:** Každý řádek má status `Done` — sekce zavádí
- **Oprava:** Přejmenovat nebo sloučit s "What Works Today"
- **Odhad:** 15 minut

### 5. docker compose config eager interpolation wrinkle
- **Závažnost:** COSMETIC; neovlivňuje real usage
- **Odhad:** Možná neřešit vůbec

---

## Dlouhodobé / architektonické

### Multi-provider rate limiting
- ADR-013 zaznamenalo potenciální potřebu per-provider semaphore pro Proxmox API rate limits
- **Trigger:** Přidání třetího BaseProvider implementace nebo pozorovaný throttling v produkci

### Per-task timeouts (ADR-016)
- `execute_with_timeout()` existuje a je otestováno
- **Trigger:** Blueprint schema získá `timeout_seconds` field; nebo hung task incident v produkci

---

## Poznámka k pořadí

Doporučené pořadí pro příští sezení:
1. **R-001 (SHA pinning)** — nejvyšší bezpečnostní dopad, jasně vymezená práce
2. **R-012 (assert guards)** — rychlá win, zlepšení robustnosti
3. **README cleanup** — 15 minut
4. Pak R-010, R-016, R-018 dle preferencí

Ale **vždy** nejdřív: ověřit git stav, spustit testy, zkontrolovat `sessions/current.md`.
