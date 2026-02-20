from typing import Generator
from sqlmodel import create_engine, Session, SQLModel
from app.core.config import settings

# In production with Postgres, connect_args={"check_same_thread": False} is only for SQLite
connect_args = {"check_same_thread": False} if settings.DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(settings.DATABASE_URL, connect_args=connect_args)

def get_session() -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session

def init_db():
    SQLModel.metadata.create_all(engine)
