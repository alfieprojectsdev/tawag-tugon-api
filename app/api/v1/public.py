from typing import Any
from fastapi import APIRouter, Depends
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_session
from app.api.deps import get_current_tenant
from app.models.tenant import Tenant
from app.models.contact import Contact
from app.models.news import News

router = APIRouter()

@router.get("/{tenant_slug}/manifest", response_model=dict)
async def get_tenant_manifest(
    *,
    session: AsyncSession = Depends(get_session),
    tenant: Tenant = Depends(get_current_tenant)
) -> Any:
    """
    Get LGU complete manifest for offline-first sync.
    """
    statement = select(Contact).where(Contact.tenant_id == tenant.id).order_by(Contact.priority.desc())
    result = await session.execute(statement)
    contacts = result.scalars().all()
    
    return {
        "id": tenant.id,
        "name": tenant.name,
        "slug": tenant.slug,
        "logo_url": tenant.logo_url,
        "primary_color": tenant.primary_color,
        "is_active": tenant.is_active,
        "contacts": contacts
    }

@router.get("/{tenant_slug}/news", response_model=list[News])
async def get_tenant_news(
    *,
    session: AsyncSession = Depends(get_session),
    tenant: Tenant = Depends(get_current_tenant)
) -> Any:
    """
    Get LGU news/announcements for offline-first sync.
    """
    # Order by newest first
    statement = select(News).where(News.tenant_id == tenant.id).order_by(News.published_date.desc())
    result = await session.execute(statement)
    news = result.scalars().all()
    return news
