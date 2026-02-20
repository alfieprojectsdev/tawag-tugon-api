from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select
from app.db.session import get_session
from app.models.tenant import Tenant
from app.models.contact import Contact

router = APIRouter()

@router.get("/config", response_model=Tenant)
def get_lgu_config(
    *,
    session: Session = Depends(get_session),
    slug: str
) -> Any:
    """
    Get LGU configuration by slug.
    """
    statement = select(Tenant).where(Tenant.slug == slug)
    tenant = session.exec(statement).first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant

@router.get("/contacts", response_model=List[Contact])
def get_contacts(
    *,
    session: Session = Depends(get_session),
    tenant_id: int
) -> Any:
    """
    Get contacts for a specific tenant.
    """
    statement = select(Contact).where(Contact.tenant_id == tenant_id)
    contacts = session.exec(statement).all()
    return contacts
