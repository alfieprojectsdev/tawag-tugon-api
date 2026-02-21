# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Tawag-Tugon** is a multi-tenant headless CMS and backend API for Philippine Local Government Units (LGUs). It serves as the backend for a Flutter mobile app providing offline-first emergency contact directories and community newsletters for disaster risk reduction (DRR) scenarios.

## Commands

```bash
# Install/sync dependencies
uv sync

# Run development server (auto-reloads on change)
uv run uvicorn app.main:app --reload

# Seed demo data into the local SQLite database
python seed.py
```

The API runs at `http://localhost:8000` with interactive docs at `/docs` and `/redoc`.

## Architecture

### Tech Stack
- **FastAPI** with fully async handlers
- **SQLModel** (SQLAlchemy + Pydantic) for ORM and schema validation
- **SQLite** (local dev, via `aiosqlite`) / **PostgreSQL** (prod, via `asyncpg`)
- **uv** for dependency and environment management
- **JWT** (python-jose) + **bcrypt** (passlib) for authentication

### App Structure (`app/`)

| Path | Purpose |
|---|---|
| `main.py` | FastAPI app init, CORS middleware, startup `init_db()` call |
| `core/config.py` | Pydantic `Settings` loaded from `.env` (`DATABASE_URL`, `SECRET_KEY`, etc.) |
| `core/security.py` | JWT creation (`create_access_token`), password hashing/verification |
| `api/deps.py` | FastAPI dependencies: `get_current_user` (JWT→User), `get_current_tenant` (slug→Tenant) |
| `api/v1/router.py` | Mounts `/lgu` and `/public` sub-routers |
| `api/v1/lgu.py` | Auth-protected admin endpoints (login, CRUD for contacts/news/tenant) |
| `api/v1/public.py` | Unauthenticated mobile endpoint (`/{tenant_slug}/manifest`) |
| `db/session.py` | Async engine creation; auto-rewrites `sqlite://` → `sqlite+aiosqlite://` and `postgresql://` → `postgresql+asyncpg://` |
| `models/base.py` | `Base` class = `IDMixin` (int PK) + `TimeStampMixin` (created_at, updated_at) |
| `models/` | SQLModel table classes: `Tenant`, `Contact`, `News`, `User` |
| `services/scraper.py` | Placeholder for future PHIVOLCS/PAGASA data ingestion |

### API Routes

```
GET  /health                              # Health check
POST /api/v1/lgu/login                    # Auth: returns JWT
GET  /api/v1/lgu/contacts                 # Admin: list contacts for current user's tenant
POST /api/v1/lgu/contacts                 # Admin: create contact
GET  /api/v1/lgu/news                     # Admin: list news for current user's tenant
POST /api/v1/lgu/news                     # Admin: create news item
PUT  /api/v1/lgu/tenant                   # Admin: update tenant profile
GET  /api/v1/public/{tenant_slug}/manifest # Mobile: offline-sync payload (tenant + contacts)
```

### Multi-Tenancy

Every data model (`Contact`, `News`, `User`) has a `tenant_id` FK referencing `Tenant`. **All queries must be scoped by `tenant_id`** — this is the only data isolation mechanism (Shared Database, Shared Schema). The `get_current_user` dependency provides `current_user.tenant_id` for scoping in LGU endpoints.

### Database Configuration

The `DATABASE_URL` setting drives everything. `db/session.py` transparently translates the scheme prefix to its async driver at startup. For local dev, the default SQLite file `tawag_tugon.db` is created automatically on first run via `init_db()`.

### Environment Variables (`.env`)

```
DATABASE_URL=sqlite:///./tawag_tugon.db   # or postgresql://user:pass@host/db
SECRET_KEY=change-me-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Contact Model Fields of Note

- `protocol`: Routing protocol for the mobile dialer (`tel`, `viber`, `https`)
- `priority`: Integer; higher = shown first in the mobile emergency directory
- `category`: String label (e.g., `Police`, `Fire`, `Medical`, `Barangay`)
