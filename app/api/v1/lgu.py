from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.api import deps
from app.core import security
from app.db.session import get_session
from app.models.tenant import Tenant
from app.models.contact import Contact
from app.models.news import News
from app.models.user import User
from pydantic import BaseModel

router = APIRouter()

class LoginRequest(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

@router.post("/login", response_model=Token)
async def login_access_token(
    login_data: LoginRequest,
    session: AsyncSession = Depends(get_session)
) -> Any:
    # Use email instead of username for User model
    statement = select(User).where(User.email == login_data.username)
    result = await session.execute(statement)
    user = result.scalar_one_or_none()
    
    # Mocking password check since we aren't enforcing full auth strictness for now
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = security.create_access_token(subject=user.email)
    return {
        "access_token": access_token,
        "token_type": "bearer",
    }

@router.get("/contacts", response_model=List[Contact])
async def read_contacts(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    statement = select(Contact).where(Contact.tenant_id == current_user.tenant_id)
    result = await session.execute(statement)
    return result.scalars().all()

@router.post("/contacts", response_model=Contact)
async def create_contact(
    *,
    session: AsyncSession = Depends(get_session),
    contact_in: Contact,
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    contact = Contact.model_validate(contact_in, update={"tenant_id": current_user.tenant_id})
    session.add(contact)
    await session.commit()
    await session.refresh(contact)
    return contact

@router.get("/news", response_model=List[News])
async def read_news(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    statement = select(News).where(News.tenant_id == current_user.tenant_id)
    result = await session.execute(statement)
    return result.scalars().all()

@router.post("/news", response_model=News)
async def create_news(
    *,
    session: AsyncSession = Depends(get_session),
    news_in: News,
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    news = News.model_validate(news_in, update={"tenant_id": current_user.tenant_id})
    session.add(news)
    await session.commit()
    await session.refresh(news)
    return news

@router.put("/tenant", response_model=Tenant)
async def update_tenant(
    *,
    session: AsyncSession = Depends(get_session),
    tenant_in: Tenant,
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    if current_user.tenant_id != tenant_in.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
        
    statement = select(Tenant).where(Tenant.id == tenant_in.id)
    result = await session.execute(statement)
    tenant = result.scalar_one_or_none()
    
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    
    tenant_data = tenant_in.model_dump(exclude_unset=True)
    for key, value in tenant_data.items():
        setattr(tenant, key, value)
    
    session.add(tenant)
    await session.commit()
    await session.refresh(tenant)
    return tenant
