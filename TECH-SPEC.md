# Tawag-Tugon — Technical Specification (V1)

**Status:** V1 / MVP scope. Deliberately minimal.
**Working title:** "Tawag-Tugon" (placeholder — client has not approved a final name).
**Owner:** Alfie Pelicano (engineering) · Chris "Ayok" Uybengkee (product) + daughter (UI/UX, icons)

> Scope rule: every feature below traces to a stated client requirement. Anything not
> here is **deferred** or **cut** — see §6. The V1 target is ONE real LGU, fully working
> offline, demoable to a mayor.

---

## 1. Overview
A white-label mobile app + lightweight backend for Philippine LGUs. It gives constituents
an **offline-first, speed-dial directory** of emergency responders (barangay, police,
hospitals, fire) reachable via phone, Viber, or Messenger, plus a **local
news/announcements** feed per LGU. One codebase is re-skinned per LGU (name, logo/seal,
colors) so it can be presented to different city/district officials.

## 2. Client application (mobile) — Flutter
- **Framework:** Flutter (single codebase → Android + iOS), chosen for performance on
  low-end Android devices and UI consistency.
- **Local storage:** SQLite (`sqflite`). The local DB is the source of truth for the UI.
  After first successful sync, the app is fully usable with no network.
- **Screens (the entire V1 surface):**
  1. **Emergency Directory** — contacts grouped by `category`, sorted by `priority`
     (higher first). Each row is tap-to-act via native protocols: `tel:`, `viber://`,
     `https://m.me/…`.
  2. **Local News** — read-only list + detail view, cached offline, newest first, with
     pinned/high-priority items shown on top.
  3. **Branding load** — on launch the app renders the LGU's name, logo/seal, and colors
     pulled from its tenant config (no per-LGU code changes).
- **Sync model:** pull-on-open. App calls the public manifest endpoint when online, updates
  its local cache, and otherwise runs from cache. No push notifications in V1.

## 3. Backend API + minimal admin — Python / FastAPI
- **Stack:** FastAPI (async), SQLModel (SQLAlchemy + Pydantic), **SQLite** for V1
  (dev and early deployments), `uv` for env/dependency management, JWT (python-jose) +
  bcrypt (passlib) for admin auth.
- **Data models:** `Tenant`, `Contact`, `News`, `User`.
  - `Contact`: `protocol` (`tel` | `viber` | `https`), `priority` (int), `category`
    (e.g. Police, Fire, Medical, Barangay), plus label + value.
  - `News`: title, body (markdown/plain), `pinned` flag, timestamps.
  - Every row carries `tenant_id` (see §4).
- **Endpoints (already largely built — keep these):**
  - `POST /api/v1/lgu/login` — admin JWT.
  - `GET/POST /api/v1/lgu/contacts` — admin CRUD.
  - `GET/POST /api/v1/lgu/news` — admin CRUD (incl. pin).
  - `PUT /api/v1/lgu/tenant` — update LGU profile/branding.
  - `GET /api/v1/public/{tenant_slug}/manifest` — **offline-sync payload**
    (tenant branding + contacts + recent news). This is the core of the offline design.
- **Admin surface for V1:** the FastAPI `/docs` (JWT-protected) *or* a single bare web form
  is acceptable so LGU staff can add/edit a contact and post/pin an announcement without a
  developer. **Do not build a full CMS in V1.**

## 4. Data / tenancy
- **Single database, shared schema.** Isolation is enforced by a `tenant_id` column on
  every table; all queries are tenant-scoped.
- **V1 datastore is SQLite.** Keep `tenant_id` so migrating to PostgreSQL later is a
  config change, but do **not** stand up Postgres or row-level security for V1.
- **V1 branding approach:** **per-LGU locked** (simplest). GPS/location-based dynamic
  branding is deferred.

## 5. V1 Definition of Done
1. Backend runs on SQLite with the four models and the `/manifest` endpoint.
2. ONE real LGU (e.g. Quezon City — `seed_qc.py` exists) seeded with **verified** emergency
   numbers and a few announcements.
3. App boots → pulls manifest → caches locally → works fully offline afterward.
4. Directory grouped by category, sorted by priority, each row launches `tel:`/`viber://`/`m.me`.
5. News list + detail, offline-cached, newest first, pinned on top.
6. Swapping the tenant visibly re-brands the app with zero code changes.
7. LGU staff can add/edit a contact and post/pin an announcement via the minimal admin.

## 6. Explicitly deferred / cut (NOT in V1)
| Item | Status | Note |
|---|---|---|
| P2P BLE / Wi-Fi Direct mesh | **Cut/park** | Not requested; heavy native + battery cost. |
| PostgreSQL + row-level security | **Defer** | SQLite is enough; keep `tenant_id` open door. |
| PHIVOLCS / PAGASA hazard scraping | **Defer** | Client wants local barangay news, not national feeds. |
| Push notifications (Firebase/OneSignal) | **Defer** | Pull-on-sync is enough for V1. |
| Automated LGU-webpage scraper | **Stretch, later** | Fragile; V1 uses manual admin entry. |
| GPS dynamic branding switch | **Defer** | Ship per-LGU locked first. |
| Multi-LGU onboarding at scale | **Narrow** | Prove ONE LGU end-to-end first. |

## 7. Open questions (blockers)
- Final app name?
- Which single LGU is the first real demo target?
- Delivery of app icon, LGU logo/seal, color palette, initial contacts + announcements?
- Confirm per-LGU-locked branding is acceptable to start.
- "Messenger contact" = per-responder `m.me` deep links, or phone/Viber only for now?