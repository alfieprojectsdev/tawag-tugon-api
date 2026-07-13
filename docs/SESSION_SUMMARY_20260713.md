# Session Summary — 2026-07-13

**Focus:** Local build toolchain, seeded demo data, v0.1.0 APK shipped and
field-tested; first on-device bug found and fixed.

---

## What happened

### 1. Local Flutter/Android toolchain installed (billing fix stays deferred)
- Flutter 3.44.6 stable → `/home/finch/flutter` (pre-existing PATH entry in
  `.bashrc` now valid again).
- Android SDK → `/home/finch/Android/Sdk`: cmdline-tools 13114758,
  platform-tools, platform android-36, build-tools 36.0.0; licenses accepted.
- `flutter doctor`: Flutter ✓, Android toolchain ✓.
- First release build ~10 min cold; warm rebuilds 1–2 min.

### 2. Demo data seeded (app + server)
- **Speed dial:** 13 verified 2026 hotlines (911, 122, 143, QCPD 8925-8326,
  QC Fire 8330-2344, DPOS Rescue 8928-4396, Red Cross QC 8403-1063, MMDA 136,
  Bantay Bata 163, Brgy San Vicente 8441-5644, Meralco/Manila Water/PLDT).
  Landlines in NTC 8-digit format with (02) prefix; fake test contacts and
  outdated 7-digit numbers dropped. Bayantel skipped (defunct).
- **News:** 5 QC program articles (QCitizen ID, Nano-Enterprise Registration,
  Start-Up QC, Start-Up Student Competition, No Woman Left Behind), text-only,
  condensed from quezoncity.gov.ph with source URLs.
- App side: `lib/seed_data.dart`, seeded on fresh install (`onCreate`) and
  via DB v3→v4 upgrade. Server side: `seed_qc.py` mirrors the data; sync
  dedupes news on `source_url`. Local `tawag_tugon.db` reseeded and verified.

### 3. v0.1.0 release published (local build, manual upload)
- `gh release create v0.1.0 <apk> --prerelease`, later `--clobber` re-uploads.
- Download link (public, no login):
  https://github.com/alfieprojectsdev/tawag-tugon-api/releases/download/v0.1.0/app-release.apk
- Public-link download hash-verified (sha256) against local build after each
  upload.

### 4. Repo hygiene
- Client-communication drafts moved out of version control entirely
  (history rewritten with git-filter-repo, refs force-pushed, files kept
  locally untracked). `.gitignore` now blocks `docs/*reply-ayok*.md`,
  `docs/*ayok-reply*.md`, `docs/HANDOVER.md`.
- Note: filter-repo needed `GIT_CONFIG_GLOBAL=/dev/null` (multi-line git
  alias in global config breaks its parser) and `uvx git-filter-repo`
  (stale pip shim was broken).
- Release/tag survived the rewrite; APK link unchanged.

### 5. First field bug: "Read Original on Web" dead on device
- Test device: **Galaxy A07 5G (SM-A076B/DS)**, Android 15/One UI.
- Cause: Android 11+ package visibility — `canLaunchUrl()` returns false
  without `<queries>` manifest entries, button silently no-ops.
- Fix (commit `40be7da`): manifest `<queries>` now declares VIEW https +
  DIAL intents and Viber/Messenger packages; code launches directly instead
  of gating on `canLaunchUrl` and shows a snackbar on real failure.
- Fixed APK rebuilt, re-uploaded to v0.1.0, hash-verified. Reinstalls over
  the old build in place (same debug signature).

---

## State / next session

| # | Task | Status |
|---|---|---|
| 1 | GitHub Actions billing fix | deferred — local build path works |
| 2 | `LguConfig` + theme/tenant wiring (incl. per-LGU `android:label`) | pending |
| 3 | Contact rows: `launchContact` protocol switch + ripple + haptics | pending (manifest side already done) |
| 4 | SafeArea / edge-to-edge / status-bar theme | pending |
| 5 | Manifest queries | **done** (label half moved to #2) |
| 6 | Launcher icon + splash tooling | pending, assets still awaited |

Uncommitted (intentionally): `gradle.properties` + `pubspec.lock`
(build-generated), local-only client-comms docs.

Verify on device: browser button now opens Chrome/Samsung Internet from the
news detail screen.
