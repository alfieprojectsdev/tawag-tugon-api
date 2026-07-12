# Session Summary — 2026-07-12

**Focus:** Ship first sideloadable APK via GitHub Actions; sign-off doc polish;
Android-polish gap analysis.

---

## What happened

### 1. CI workflow push unblocked (`workflow` scope)
- Push of `.github/workflows/release-apk.yml` was rejected:
  `refusing to allow an OAuth App to create or update workflow ... without workflow scope`.
- Fixed with `gh auth refresh -h github.com -s workflow` (second attempt succeeded;
  first browser auth timed out).
- `main` pushed (commit `48cb438`), tag `v0.1.0` pushed.
- Cleaned a stale staged deletion of the workflow file before later commits.

### 2. APK build — **STILL BLOCKED (billing)**
- All runs died with `startup_failure`, 0s, 0 jobs. Workflow YAML itself is valid
  (GitHub registered it as `active`).
- Repo made **public** by Alfie → startup_failure changed to a real job failure with
  explicit annotation:
  > "The job was not started because your account is locked due to a billing issue."
- **Account-level lock** on `alfieprojectsdev` — public repo doesn't bypass it.
- **Action required (Alfie, in browser):** https://github.com/settings/billing —
  fix payment method / settle balance, then re-run:
  `gh run rerun 29198980045 --repo alfieprojectsdev/tawag-tugon-api`
  (or dispatch fresh: `gh workflow run release-apk.yml -f release_name=v0.1.0`).
- Note: tag-push trigger won't re-fire on the existing `v0.1.0` tag; use
  workflow_dispatch or delete+repush the tag.

### 3. Repo now public — secret scan done
- No `.env` / `.db` ever committed (checked full history).
- `SECRET_KEY` in `app/core/config.py` is a placeholder default.
- `seed_qc.py` uses dummy password `"your_password"` — placeholder only; change if
  ever seeded on a real deployment.

### 4. Sign-off doc rendering fix
- `docs/V1-SCOPE-SIGNOFF.md`: added `<br>` to For/From/Purpose header block and
  Name/Date/Signature block (single newlines collapse in GitHub's renderer).
- Committed `0717cb4`, pushed.
- Messenger message to Ayok drafted (link + context + meet-up ask) — sending is
  Alfie's move.

### 5. ANDROID-POLISH.md gap analysis (tawag_tugon_app/)
Current state vs `docs/ANDROID-POLISH.md`:

**Already in place:** Material 3 + `ColorScheme.fromSeed` (seed hardcoded
`0xFF0033A0`, `lib/main.dart:22`), InkWell on news cards, `url_launcher` dep.

**Gaps (implement in doc §6 order):**
1. **`LguConfig`** — no `assets/` dir, no config file. Doc §4 Dart sketch is
   drop-in-ready. Wire: async `main()`, `lgu.appName` → `MaterialApp.title`,
   `lgu.brandColor` → `fromSeed`, and replace hardcoded tenant slug `qc` in
   `baseUrl` (`lib/main.dart:67`) with `lgu.tenantSlug`.
2. **Contact rows** — `_buildContactCard` (`lib/main.dart:303`) drops `protocol`
   (already synced into SQLite). Add doc §3 `launchContact` switch
   (viber/https/tel fallback), whole-row `onTap`, `HapticFeedback.selectionClick()`.
3. **System chrome** — no SafeArea/edge-to-edge/status-bar theming anywhere.
4. **Manifest/branding** — `android:label` still `tawag_tugon_app` (manifest:3);
   `<queries>` has only Flutter's PROCESS_TEXT default, missing Viber/Messenger/DIAL
   entries; `flutter_launcher_icons` + `flutter_native_splash` not added
   (icon/splash assets wait on Ayok's daughter — sign-off item 3).
5. **Skip:** PopScope (2-screen nav fine), text-scale (nothing clamps it).

**Drive-by cleanups when in there:** `print` → `debugPrint`, `withOpacity`
deprecation (`lib/main.dart:315`).

---

## Pending / tomorrow queue

| # | Task | Blocker |
|---|---|---|
| 1 | Fix GitHub billing lock (settings/billing) | Alfie, browser only |
| 2 | Re-run APK workflow, verify release + APK asset on v0.1.0 | after #1 |
| 3 | Send Ayok the sign-off link + drafted message | Alfie |
| 4 | Implement `LguConfig` + theme/tenant wiring | — |
| 5 | Contact rows: `launchContact` protocol switch + ripple + haptics | — |
| 6 | SafeArea / edge-to-edge / status-bar theme | — |
| 7 | Manifest: per-LGU label, Viber/Messenger/DIAL `<queries>` | — |
| 8 | Add launcher-icon/splash packages (assets pending from Ayok's daughter) | sign-off item 3 |
