from fastapi import APIRouter
from app.api.v1 import lgu, public

api_router = APIRouter()
api_router.include_router(lgu.router, prefix="/lgu", tags=["lgu"])
api_router.include_router(public.router, prefix="/public", tags=["public"])
