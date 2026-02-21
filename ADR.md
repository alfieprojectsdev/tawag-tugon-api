### **Architecture Decision Records (ADRs)**

#### **ADR 001: Mobile Application Framework Strategy**

* **Context:** The application must run reliably during disasters (offline access required), have deep hooks into native hardware (dialer, GPS), and be highly maintainable for a solo developer or small team managing multiple LGU deployments. We evaluated Flutter and React Native for this cross-platform requirement. 
* **Decision:** We will exclusively use **Flutter** for the mobile client framework. 
* **Consequences:** * *Positive:* Guarantees pixel-perfect UI rendering across devices (crucial for matching custom LGU design templates); provides superior performance on older, low-end Android devices typical in target demographics; offers highly stable local database integration via `sqflite` for our offline-first architecture. 
  * *Negative:* Implementing the Phase 3 P2P Bluetooth Mesh network will require writing custom native code (Kotlin/Swift) via Method Channels, as Flutter's ecosystem for low-level hardware networking is less mature than React Native's.



#### **ADR 002: Offline-First Data Synchronization**

* **Context:** In disaster risk reduction (DRR) scenarios, cellular infrastructure frequently fails. The app is useless if it requires a network fetch to display emergency numbers.
* **Decision:** The mobile client will implement an offline-first architecture. A local SQLite database will serve as the single source of truth for the UI. The app will passively sync with the FastAPI backend to update its local cache whenever an internet connection is detected.
* **Consequences:**
* *Positive:* Zero-latency UI; 100% availability of critical data during emergencies.
* *Negative:* Increases complexity on the mobile client, requiring conflict resolution and robust background sync logic.



#### **ADR 003: Multi-Tenant Data Isolation Strategy**

* **Context:** The platform will host multiple LGUs (barangays, cities, districts). Spinning up separate databases for each LGU (Database-per-Tenant) would create massive infrastructure overhead and costs.
* **Decision:** We will use a Shared Database, Shared Schema model in PostgreSQL. Every table (Contacts, News, Users) will include a `tenant_id` foreign key. Row-Level Security (RLS) or strict ORM scoping will be enforced at the API layer to prevent data leakage between LGUs.
* **Consequences:**
* *Positive:* Highly cost-effective; allows rapid onboarding of new LGUs; simplifies database migrations and backups.
* *Negative:* Requires strict discipline in backend queries to ensure `tenant_id` is always passed and validated.

#### **ADR 004: Future Phase - P2P Mesh Communication**

* **Context:** In a Category 5 typhoon or major earthquake (like "The Big One"), cell towers will lose power or be destroyed. Citizens and LGU responders will need a way to transmit SOS coordinates and short-burst text data without carrier signals.
* **Decision:** The mobile client will eventually integrate a mesh networking protocol utilizing BLE and Wi-Fi Direct. Devices will act as autonomous nodes, relaying encrypted JSON payloads (containing sender ID, GPS coordinates, and timestamp) across the network until they reach an LGU responder device or an internet-connected gateway.
* **Consequences:** * *Positive:* Provides ultimate resilience; guarantees the app remains functional in catastrophic "blackout" scenarios.
* *Negative:* Significant increase in battery consumption when active; introduces complex cross-platform routing and payload optimization challenges.