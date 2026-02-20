Get some rest! Building a system that handles disaster data requires a clear head.

Here is the exact terminal setup and folder structure you can copy and paste tomorrow morning to get `tawag-tugon-api` off the ground.

### 1. Initialize the Project

Run this in your terminal to create the directory, initialize it with `uv`, and grab the core dependencies (FastAPI, a server, and an ORM):

```bash
mkdir tawag-tugon-api
cd tawag-tugon-api
uv init
uv add fastapi uvicorn sqlmodel

```

### 2. The Modular Folder Structure

For a multi-tenant application, you want to separate your routing from your business logic right away. Create an `app` directory and structure it like this:

```text
tawag-tugon-api/
├── pyproject.toml          # Your dependencies, managed cleanly by uv
├── .venv/                  # The isolated environment
├── app/
│   ├── __init__.py
│   ├── main.py             # The FastAPI initialization and middleware
│   ├── api/                
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py   # Mounts the sub-routers
│   │       ├── lgu.py      # Endpoints for the LGU Admin (CMS)
│   │       └── public.py   # Endpoints for the Mobile App to fetch data
│   ├── core/               
│   │   ├── __init__.py
│   │   ├── config.py       # Pydantic BaseSettings for your env vars
│   │   └── security.py     # JWT logic for the LGU admins
│   ├── models/             
│   │   ├── __init__.py
│   │   ├── base.py         # Base SQLModel class
│   │   ├── tenant.py       # LGU Profiles (Branding, Config)
│   │   └── contact.py      # Emergency Numbers (with tenant_id)
│   ├── db/                 
│   │   ├── __init__.py
│   │   └── session.py      # Database engine and dependency injections
│   └── services/           
│       ├── __init__.py
│       └── scraper.py      # Your future logic for pulling external newsletters
└── .gitignore

```

### 3. Your Quickstart `main.py`

Drop this into `app/main.py` so you have a working server the second you wake up:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Tawag-Tugon API",
    description="Headless CMS and backend for the LGU Emergency Mesh App",
    version="0.1.0",
)

# Standard CORS for your web-based control center
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Update this to your frontend domains later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "Tawag-Tugon API is running. Ready for LGU integration."}

# To run it tomorrow:
# uv run uvicorn app.main:app --reload

```

Bookmark this, close your laptop, and get some sleep!

Would you like me to draft the `tenant.py` and `contact.py` database models when you're back online so we can lock in that multi-tenant structure?