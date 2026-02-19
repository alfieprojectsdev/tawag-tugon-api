# 📱 Tawag-Tugon API

**Tawag-Tugon** (Call & Response) is a high-resilience, multi-tenant digital infrastructure designed for Local Government Units (LGUs) in the Philippines. It serves as a white-label backbone for disaster risk reduction (DRR) and community engagement.

The system bridges the gap between **Agap** (Preparedness) and **Tugon** (Response) by providing constituents with an offline-first directory of emergency responders and a localized community newsletter.

---

## 🏗️ Architecture Overview

This repository contains the **Headless CMS and Backend API** built with **Python**, **FastAPI**, and **SQLModel**, managed via **`uv`**.

* **Multi-Tenancy:** Single-database, shared-schema architecture utilizing `tenant_id` for data isolation across different LGUs.
* **Offline-First Sync:** Optimized JSON payloads designed to be cached locally by mobile clients, ensuring 100% availability of emergency contacts during carrier blackouts.
* **Deep-Link Routing:** Dynamic configuration for triggering native protocols (`tel:`, `viber://`, `https://m.me/`).
* **Headless CMS:** A centralized portal for LGU Public Information Officers (PIOs) to manage directories and announcements without technical overhead.

---

## 🚀 Quickstart

### Prerequisites

* [Python 3.12+](https://www.python.org/)
* [`uv`](https://www.google.com/search?q=%5Bhttps://github.com/astral-sh/uv%5D(https://github.com/astral-sh/uv)) (Extremely fast Python package manager)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/alfieprojectsdev/tawag-tugon-api.git
cd tawag-tugon-api

```


2. **Sync dependencies:**
```bash
uv sync

```


3. **Run the development server:**
```bash
uv run uvicorn app.main:app --reload

```



The API will be available at `http://localhost:8000` with interactive documentation at `/docs`.

---

## 📂 Project Structure

```text
app/
├── api/v1/         # Versioned API endpoints (Admin & Public)
├── core/           # Security (JWT), Config (Pydantic Settings)
├── db/             # Session management & migrations
├── models/         # SQLModel schemas (Tenants, Contacts, News)
└── services/       # Business logic (Scrapers, Notification triggers)

```

---

## 🗺️ Roadmap

### Phase 1: The Backbone (Current)

* [ ] Multi-tenant LGU configuration engine.
* [ ] Offline-sync-ready emergency directory API.
* [ ] Basic Headless CMS for newsletter publishing.

### Phase 2: Engagement & Alerts

* [ ] Push notification integration (Firebase/OneSignal).
* [ ] Real-time weather/geohazard data scraping (via PHIVOLCS/PAGASA).

### Phase 3: The "Red Alert" Mesh (Experimental)

* [ ] Implementation of Bluetooth Low Energy (BLE) / Wi-Fi Direct protocols.
* [ ] Peer-to-peer message routing for total network blackout scenarios.

---

## 🤝 Collaboration

This project is part of a collaborative effort involving engineering, UI/UX design, and LGU outreach.

* **Engineering:** Alfie Pelicano
* **UI/UX & Branding:** Chris U. & Team

---

## ⚖️ License

Proprietary / Private (Internal Development)