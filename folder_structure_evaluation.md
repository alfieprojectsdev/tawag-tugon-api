# Folder Structure Evaluation

This document evaluates the potential effects of reorganizing the `tawag-tugon` repository from its current API-centric structure to a modular monorepo structure.

## 1. Overview of Structures

### Current Structure (API-Centric)
The repository root (`/`) is effectively the API project, with other applications nested inside or alongside API components.

```text
/home/finch/repos/tawag-tugon-api/  (Root)
├── app/                            (API Source)
├── pyproject.toml                  (API Config)
├── uv.lock                         (API Lockfile)
├── seed.py                         (API Script)
├── tawag_tugon_app/                (Flutter App - Nested)
└── tawag-tugon-admin/              (Astro CMS - Planned/Nested)
```

### Proposed Structure (Modular Monorepo)
The repository root becomes a container for distinct projects. Each project is a sibling directory.

```text
/home/finch/repos/tawag-tugon/      (Root)
├── tawag-tugon-api/                (API Project)
│   ├── app/
│   ├── pyproject.toml
│   ├── uv.lock
│   └── seed.py
├── tawag-tugon-admin/              (Astro CMS)
│   ├── src/
│   ├── package.json
│   └── astro.config.mjs
└── tawag_tugon_app/                (Flutter App)
    ├── lib/
    ├── pubspec.yaml
    └── android/ios/etc
```

---

## 2. Comparative Analysis

### A. Architecture & Separation of Concerns

| Feature | Current Structure | Proposed Structure |
| :--- | :--- | :--- |
| **Concept** | "The API is the main project; others are add-ons." | "A suite of related applications (API, Admin, Mobile)." |
| **Clarity** | **Low.** The root directory is cluttered with API files (`seed.py`, `pyproject.toml`) mixed with project folders (`tawag_tugon_app`). | **High.** Root is clean. It's immediately obvious where each project lives. |
| **Scalability** | **Medium.** Adding more services (e.g., a worker, a second frontend) further clutters the root. | **High.** New services are just new top-level directories. |

**Verdict:** The **Proposed Structure** is superior for long-term maintainability and mental modeling.

### B. Developer Experience (DevEx) & Tooling

| Tool | Impact of Reorganization |
| :--- | :--- |
| **Python / uv** | **Change Required.** Commands must be run from inside `tawag-tugon-api/` instead of the root. <br>Example: `cd tawag-tugon-api && uv run uvicorn ...` |
| **Flutter** | **Neutral.** Flutter is already in a subdirectory. Developers already `cd tawag_tugon_app` to run commands. The relative path to root changes, but this rarely affects Flutter apps unless they use root-level scripts. |
| **Astro (Node)** | **Neutral.** Similar to Flutter, commands will be run inside `tawag-tugon-admin/`. |
| **IDE (VS Code)** | **Improved.** You can open the root as a "Workspace" and have distinct folders for each project. VS Code handles nested projects well, but a clean root is easier to navigate. |

**Verdict:** Slight adjustment in workflow (remembering to `cd`), but standard for multi-project repositories.

### C. CI/CD & Deployment

| Aspect | Current Structure | Proposed Structure |
| :--- | :--- | :--- |
| **Docker** | **Confusing.** Dockerfiles for the API usually copy `.` (everything). This unwittingly copies the `tawag_tugon_app` folder into the API container unless explicitly `.dockerignore`d. | **Clean.** `tawag-tugon-api/Dockerfile` context is just the API folder. No risk of leaking mobile app source code into the API container. |
| **Pipelines** | **Mixed.** Scripts run at root for API, but need to `cd` for others. | **Uniform.** All pipeline steps follow the pattern: `cd <project> && <build-command>`. |
| **Git History** | **Risk.** Moving files can complicate `git blame` if not done with `git mv`. | **Manageable.** Modern git handles moves well. |

**Verdict:** The **Proposed Structure** significantly reduces the risk of incorrect build contexts (e.g., including the 500MB+ `node_modules` or `build` artifacts of the app in the API container).

---

## 3. Migration Strategy

To move from the current state to the proposed state with minimal disruption:

### Step 1: Prepare the API Directory
Create the new folder for the API and move all API-specific files into it.

```bash
mkdir tawag-tugon-api
git mv app pyproject.toml uv.lock seed.py seed_qc.py session-log_*.md tawag-tugon-api/
# Move the API-specific documentation
git mv CLAUDE.md tawag-tugon-api/
# Move the API-specific README
git mv README.md tawag-tugon-api/
```

### Step 2: Handle Shared/Root Files
Decide which files remain at the root or move to a `docs/` folder.
- `TECH-SPEC.md` & `ADR.md`: These describe the whole system. Keep them at the root or move to a `docs/` folder.
- `folder-structure.md`: This describes the internal API structure. Move to `tawag-tugon-api/`.
- `.gitignore`: The root `.gitignore` currently ignores Python artifacts. You should create a new root `.gitignore` that ignores generic IDE files and specific project artifacts, or keep the existing one and clean it up.
- **New Root README:** Create a new `README.md` at the root that links to the three sub-projects.

### Step 3: Move the App and Admin
Move the existing app directory and planned admin directory to be siblings of the new `tawag-tugon-api` folder.

```bash
# Since they are already subdirectories, they might just stay where they are relative to the new root,
# or be moved if the parent folder itself is being renamed.
```

### Step 4: Update References
- **Dockerfiles:** Update `COPY . .` to copy from the correct context.
- **CI/CD Configs:** Update paths (e.g., `working-directory: ./tawag-tugon-api`).
- **Imports:** Verify no local scripts used hardcoded paths like `../tawag_tugon_app`. (Our analysis shows `seed.py` and `app` are self-contained).

---

## 4. Recommendation

**Strongly Recommend: PROPOSED STRUCTURE**

The current "API-as-Root" structure is a common pattern for single-purpose backend repos, but it becomes an anti-pattern as soon as a frontend (Mobile/Web) is added.

**Key Benefits of Reorganizing:**
1.  **Isolation:** Changes in the Mobile App directory clearly do not affect the API build context.
2.  **Navigation:** It is easier for a new developer to understand "Here is the API, here is the Admin, here is the App."
3.  **Future-Proofing:** Ready for a Monorepo tool (like Nx, Turborepo, or Bazel) if the project grows further.
