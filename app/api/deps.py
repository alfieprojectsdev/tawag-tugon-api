from typing import Generator, Optional, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from app.core import security
from app.core.config import settings
from app.db.session import get_session
from app.models.user import User
from app.models.tenant import Tenant

reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/lgu/login"
)

async def get_current_user(
    session: AsyncSession = Depends(get_session),
    token: str = Depends(reusable_oauth2)
) -> User:
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[security.ALGORITHM]
        )
        token_data = payload.get("sub")
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
        )
    # the subject in token_data could be email
    statement = select(User).where(User.email == token_data)
    result = await session.execute(statement)
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

async def get_current_tenant(
    session: AsyncSession = Depends(get_session),
    tenant_slug: Optional[str] = None # Or extract from headers if not in path
) -> Tenant:
    if not tenant_slug:
        raise HTTPException(status_code=400, detail="tenant_slug is required")
    statement = select(Tenant).where(Tenant.slug == tenant_slug)
    result = await session.execute(statement)
    tenant = result.scalar_one_or_none()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    return tenant
