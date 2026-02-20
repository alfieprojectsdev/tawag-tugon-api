from typing import Optional, List
from sqlmodel import Field, SQLModel, Relationship
from app.models.base import Base

class Tenant(Base, table=True):
    name: str = Field(index=True)
    slug: str = Field(unique=True, index=True)
    logo_url: Optional[str] = None
    primary_color: Optional[str] = None
    is_active: bool = Field(default=True)
    
    # Relationships
    contacts: List["Contact"] = Relationship(back_populates="tenant")
