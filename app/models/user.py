from typing import Optional
from sqlmodel import Field, Relationship
from app.models.base import Base

class User(Base, table=True):
    email: str = Field(unique=True, index=True)
    hashed_password: str
    role: str = Field(default="admin")
    
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenant.id")
    tenant: Optional["Tenant"] = Relationship(back_populates="users")
