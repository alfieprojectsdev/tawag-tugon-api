# 📱 Tawag-Tugon

**Tawag-Tugon** (Call & Response) is a white-label emergency-directory app + lightweight
backend for Philippine Local Government Units (LGUs). It gives constituents an
**offline-first, speed-dial directory** of emergency responders — barangay, police,
hospitals, fire — reachable by phone, Viber, or Messenger, plus a **local
announcements** feed. One codebase is re-skinned per LGU (name, seal, colors), so it can
be presented to different city/district officials.

> **Scope note:** This project is intentionally scoped to a minimal **Version 1**. The V1
> target is **one real LGU, fully working offline, demoable to a mayor.** Features beyond
> that are parked in the roadmap under "Later" and are not being built yet. See
> `TECH-SPEC.md` for the authoritative V1 spec.

---

## 🏗️ Architecture Overview

Monorepo with a **Flutter** mobile client and a **Python / FastAPI** backend + minimal admin.

- **Offline-first:** the mobile app caches the emergency directory and recent
  announcements in local SQLite, so critical contacts stay 100% available during carrier
  blackouts. After the first sync, the app runs fully offline.
- **Tap-to-act:** native protocol deep links (`tel:`, `viber://`, `https://m.me/…`).
- **White-label:** per-LGU branding (name, logo/seal, colors) and data are loaded from a
  tenant config — no code changes to spin up a new LGU's version.
- **Multi-tenant (single DB, shared schema):** every row carries a `tenant_id`; all queries
  are tenant-scoped. V1 runs on SQLite; the `tenant_id` design keeps a later PostgreSQL move
  a config change, not a rewrite.
- **Minimal admin:** LGU staff update their own numbers and post/pin announcements without
  a developer (JWT-protected `/docs` or a bare web form for V1 — **not** a full CMS).

## 🚀 Quickstart

### Prerequisites
- Python 3.12+
- [uv](https://github.com/astral-sh/uv) (fast Python package manager)

### Installation
```bash
git clone https://github.com/alfieprojectsdev/tawag-tugon-api.git
cd tawag-tugon-api
uv sync
python seed_qc.py            # seed one demo LGU (Quezon City)
uv run uvicorn app.main:app --reload
```
The API runs at `http://localhost:8000` with interactive docs at `/docs`.
The mobile client's offline-sync payload comes from
`GET /api/v1/public/{tenant_slug}/manifest`.

## 📂 Project Structure
```
app/
├── api/v1/     # Versioned API endpoints (lgu = admin, public = mobile)
├── core/       # Security (JWT), Config (Pydantic Settings)
├── db/         # Session management
├── models/     # SQLModel schemas (Tenant, Contact, News, User)
└── services/   # Business logic
tawag_tugon_app/ # Flutter mobile client
```

## 🗺️ Roadmap

### ✅ Phase 1 — V1 / MVP (current focus)
The entire product for V1. Definition of done:
- [ ] Backend on SQLite with `Tenant`, `Contact`, `News`, `User` + `/manifest` endpoint.
- [ ] **One real LGU** (Quezon City) seeded with verified emergency numbers + a few
      announcements.
- [ ] App boots → pulls manifest → caches locally → **works fully offline** afterward.
- [ ] Directory grouped by category, sorted by priority; each row launches
      `tel:` / `viber://` / `m.me`.
- [ ] News list + detail, offline-cached, newest first, pinned items on top.
- [ ] Swapping the tenant visibly re-brands the app with **zero code changes**
      (per-LGU locked branding).
- [ ] Minimal admin so LGU staff can add/edit a contact and post/pin an announcement.

### 🔜 Later — deferred, not in V1
Deliberately parked until V1 lands and proves out with one real LGU:
- PostgreSQL + row-level security (V1 uses SQLite; `tenant_id` keeps the door open).
- Automated scraper to pull announcements from an LGU's existing public webpage
  (V1 uses manual admin entry).
- Push notifications (Firebase / OneSignal).
- Real-time weather / geohazard feeds (PHIVOLCS / PAGASA).
- GPS-based dynamic branding switching (V1 ships per-LGU locked).
- Onboarding many LGUs at scale.

### 🧪 Someday / maybe (research)
- P2P **BLE / Wi-Fi Direct mesh** for total-blackout SOS relaying. High native complexity
  and battery cost; not committed.

## 🤝 Collaboration
- **Engineering:** Alfie Pelicano
- **UI/UX & Branding:** Chris "Ayok" Uybengkee & team (app icons / LGU assets)

## ⚖️ License
Proprietary / Private (Internal Development)
