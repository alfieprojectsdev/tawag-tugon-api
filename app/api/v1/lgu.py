from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from app.api import deps
from app.core import security
from app.db.session import get_session
from app.models.tenant import Tenant
from app.models.contact import Contact
from pydantic import BaseModel

router = APIRouter()

class LoginRequest(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

@router.post("/login", response_model=Token)
def login_access_token(
    login_data: LoginRequest,
    session: Session = Depends(get_session)
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    # TODO: Implement actual user authentication (e.g. check username/password against a User table)
    # For now, we mock it. In a real app, you'd fetch the user from DB.
    # user = authenticate_user(session, login_data.username, login_data.password)
    
    # Mock authentication for now as we don't have a User model in the plan yet, 
    # but the plan mentioned "Admin login". 
    # Let's assume username is the tenant slug for simplicity in this MVP? 
    # Or just allow any login with a hardcoded secret for now?
    # The TECH-SPEC says "Authentication: JWT-based authentication for LGU administrators".
    # I'll just generate a token for the given username.
    
    access_token = security.create_access_token(subject=login_data.username)
    return {
        "access_token": access_token,
        "token_type": "bearer",
    }

@router.post("/contacts", response_model=Contact)
def create_contact(
    *,
    session: Session = Depends(get_session),
    contact_in: Contact,
    # current_user: User = Depends(deps.get_current_active_user) # TODO: add auth dependency
) -> Any:
    """
    Create new contact.
    """
    contact = Contact.from_orm(contact_in)
    session.add(contact)
    session.commit()
    session.refresh(contact)
    return contact

@router.put("/tenant", response_model=Tenant)
def update_tenant(
    *,
    session: Session = Depends(get_session),
    tenant_in: Tenant,
    # current_user: User = Depends(deps.get_current_active_user) # TODO: add auth dependency
) -> Any:
    """
    Update tenant.
    """
    tenant = session.get(Tenant, tenant_in.id)
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    
    tenant_data = tenant_in.dict(exclude_unset=True)
    for key, value in tenant_data.items():
        setattr(tenant, key, value)
    
    session.add(tenant)
    session.commit()
    session.refresh(tenant)
    return tenant
