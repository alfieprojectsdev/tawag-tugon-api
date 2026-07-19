# Session Summary — 2026-07-19

**Focus:** Mine a React Native course write-up for ideas portable to this
Flutter project. Analysis and planning only — no code changed, no doc written
yet.

---

## What happened

### 1. Source material triaged
`~/Downloads/Master Full-Stack Mobile Development with React Native.md` is a
21-line freeCodeCamp course announcement, not a technical document. Usable
content is the stack it implies: Expo/React Native, NativeWind, Sentry,
Zustand, Drizzle + Neon Postgres, Clerk.

Alfie clarified that "React Native for the mobile fallback" means **in-app
fallback behaviour** (offline states, failed sync, degraded UI), not a framework
migration. So RN is treated as a source of resilience patterns only.

### 2. Plan written, handed to Ultraplan
Planned deliverable is `docs/RESILIENCE-AND-FEEDBACK.md`, a sibling to
`docs/ANDROID-POLISH.md` in the same shape (guardrail, checklists, short Dart
sketches, out-of-scope section, order of work). Sections: course triage;
fallback/degraded states; NativeWind→design tokens; Sentry crash + feedback
with a hard privacy subsection; deferred/rejected; order of work.

**Status: plan is in cloud review and not yet approved. The document does not
exist yet.**
Review link: https://claude.ai/code/session_013U4LqkiK9zrGJDe72nEP7u

### 3. Verified findings from exploration

**Real bug — `protocol` never survives a sync.** `app/models/contact.py` has no
`protocol` field, though `CLAUDE.md` documents one and `TECH-SPEC.md:41`
specifies `tel`/`viber`/`https`. `lib/seed_data.dart` sets protocols and
`main.dart:87` reads `item['protocol'] ?? 'tel'`, so bundled data is correct —
but the first successful sync calls `clearContacts()` and re-inserts from a
manifest that never carries the field, permanently degrading every contact to
`tel`. Blocks queued task #3: `launchContact` routing would work on a fresh
install and silently stop after any sync.

**Sync failure is invisible.** `_syncWithServer` (`main.dart:61-124`) funnels
everything into a bare `print` at :119; non-200 responses don't raise, so a 500
is equally silent (:93, :114). Since seed data guarantees non-empty lists, the
empty-state text at :180/:201 — previously the only hint — is now unreachable.
Compounding it, `Env.serverIp` is a LAN address, so every release build off that
network fails sync forever with no signal.

**Security (repo is public):**
- `app/core/config.py:12` — `SECRET_KEY` still defaults to
  `"your-secret-key-here"`; the fallback signing key is world-readable.
- `app/main.py:17` — CORS `allow_origins=["*"]`.
- Create endpoints accept the table model as request body, so `id` is
  client-settable. Lower severity than it looks: `lgu.py:57` overrides
  `tenant_id` from the authenticated user, so tenant isolation holds.

**Two exploration claims that did NOT survive verification** — do not repeat:
no `.db` file is tracked by git, and there is no tenant_id isolation bypass.

**Hygiene:** `test/widget_test.dart` is stock boilerplate referencing a
non-existent `MyApp`, so `flutter test` fails and coverage is zero; six bare
`print` calls ship in release (stock `flutter_lints` already flags them);
`lib/env.dart` is tracked despite its "AUTO-GENERATED. DO NOT EDIT" header, so
every dev's LAN IP gets committed; `pubspec.yaml` still says
`description: "A new Flutter project."`; backend has zero exception handlers and
no logging config; `TECH-SPEC.md:74-83` lists the scraper as deferred while it
is already implemented (`app/services/scraper.py`).

### 4. Cross-platform reality check
`docs/DEMO-SCRIPT.md:43` tells the mayor "iPhone and Android? Yes, one app for
both," but no iOS build path exists anywhere in the repo. Codemagic's free tier
(500 macOS M2 minutes/month) would make that claim honest without a framework
change — and would also route around the GitHub Actions billing lock.

---

## State / next session

| # | Task | Status |
|---|---|---|
| 1 | GitHub Actions billing fix | deferred — local build path works |
| 2 | `LguConfig` + theme/tenant wiring (incl. per-LGU `android:label`) | pending |
| 3 | Contact rows: `launchContact` protocol switch + ripple + haptics | **blocked** — needs `protocol` added to the Contact model first |
| 4 | SafeArea / edge-to-edge / status-bar theme | pending |
| 5 | Manifest queries | done (2026-07-13) |
| 6 | Launcher icon + splash tooling | pending, assets still awaited |
| — | Write `docs/RESILIENCE-AND-FEEDBACK.md` | awaiting cloud plan approval |

No code changed this session. Working tree carries only the two long-standing
build-generated files (`gradle.properties`, `pubspec.lock`) plus local-only
client-comms docs.
