### **Technical Specifications (High-Level)**

**1. Project Overview**
A multi-tenant, white-label mobile application and headless CMS designed for Local Government Units (LGUs). The platform provides offline-first emergency contact routing (DRR) and dynamic community announcements (Newsletter).

**2. Client Application (Mobile)**

* **Framework:** **Flutter** (Cross-platform native) to ensure unified iOS and Android delivery from a single codebase, specifically chosen for its high performance on lower-tier Android devices and UI consistency.
* **Local Storage:** SQLite (via `sqflite`) to ensure the emergency directory and recent newsletters are fully accessible offline.
* **Core Modules:**
  * *Emergency Dialer:* Deep-linked buttons triggering native OS protocols (`tel:`, `viber://`).
  * *LGU Configurator:* Initial setup screen where the app fetches its branding and data payload based on a selected `tenant_id`.
  * *News Feed:* A read-only view of community updates, cached locally upon the last successful network request.



**3. Backend API & Headless CMS (Control Center)**

* **Language & Framework:** Python built with FastAPI for high-performance, asynchronous API routing.
* **Environment Management:** `uv` for dependency management and virtual environment resolution.
* **Authentication:** JWT-based authentication for LGU administrators accessing the CMS.
* **Core Modules:**
* *Tenant Manager:* Endpoints to handle CRUD operations for LGU profiles (branding, logos, enabled features).
* *Directory Manager:* Endpoints for updating emergency contacts linked to specific `tenant_id`s.
* *Content Publisher:* A lightweight markdown or rich-text editor for publishing newsletter items.



**4. Database Architecture**

* **Primary Datastore:** PostgreSQL.
* **Tenancy Strategy:** Single Database, Shared Schema with a strictly enforced `tenant_id` column on all tables to isolate LGU data.
