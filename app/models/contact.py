from typing import Optional
from sqlmodel import Field, SQLModel, Relationship
from app.models.base import Base

class Contact(Base, table=True):
    name: str = Field(index=True)
    phone_number: str
    avatar_url: Optional[str] = None
    category: Optional[str] = Field(default="S", description="E.g., Police, Fire, Medical, Other")
    priority: int = Field(default=0, description="Higher number means higher priority")
    
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenant.id")
    tenant: Optional["Tenant"] = Relationship(back_populates="contacts")
