from datetime import datetime
from typing import Optional
from sqlmodel import Field, Relationship
from app.models.base import Base

class News(Base, table=True):
    title: str = Field(index=True)
    content: str
    published_date: datetime = Field(default_factory=datetime.utcnow)
    
    tenant_id: Optional[int] = Field(default=None, foreign_key="tenant.id")
    tenant: Optional["Tenant"] = Relationship(back_populates="news")
