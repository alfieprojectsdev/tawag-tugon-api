from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.router import api_router
from app.core.config import settings
from app.db.session import init_db

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Headless CMS and backend for the LGU Emergency Mesh App",
    version="0.1.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Standard CORS for your web-based control center
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Update this to your frontend domains later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def on_startup():
    await init_db()

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "Tawag-Tugon API is running. Ready for LGU integration."}

# To run it tomorrow:
# uv run uvicorn app.main:app --reload