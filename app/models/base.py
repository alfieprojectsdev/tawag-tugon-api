from datetime import datetime
from typing import Optional
from sqlmodel import Field, SQLModel

class TimeStampMixin(SQLModel):
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow,  nullable=False) # In real app, update this on save

class IDMixin(SQLModel):
    id: Optional[int] = Field(default=None, primary_key=True)

class Base(IDMixin, TimeStampMixin):
    pass
