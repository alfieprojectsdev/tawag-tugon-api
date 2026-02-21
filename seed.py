import logging
from sqlmodel import Session, SQLModel, create_engine, select
from app.core.config import settings
from app.models.tenant import Tenant
from app.models.contact import Contact
from app.models.news import News
from app.models.user import User

# Configure basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Note: Adjust this to your actual database URL if not using SQLite locally for the demo
DATABASE_URL = "sqlite:///./tawag_tugon.db"
engine = create_engine(DATABASE_URL, echo=False)

def create_db_and_tables():
    logger.info("Creating database tables...")
    SQLModel.metadata.create_all(engine)

def seed_data():
    with Session(engine) as session:
        # Check if we already seeded to avoid duplicates
        statement = select(Tenant).where(Tenant.slug == "qc-district-1")
        existing_tenant = session.exec(statement).first()
        
        if existing_tenant:
            logger.info("Database already seeded. Skipping.")
            return

        logger.info("Seeding Tenants...")
        
        # 1. Create Quezon City District 1 Profile
        qc_tenant = Tenant(
            name="Quezon City - District 1",
            slug="qc-district-1",
            primary_color="#0033A0", # QC Blue
            logo_url="https://via.placeholder.com/150/0033A0/FFFFFF?text=QC+D1",
            is_active=True
        )
        
        # 2. Create Vigan City Profile
        vigan_tenant = Tenant(
            name="Vigan City Rescue",
            slug="vigan-city",
            primary_color="#8B0000", # Heritage Red
            logo_url="https://via.placeholder.com/150/8B0000/FFFFFF?text=Vigan",
            is_active=True
        )

        session.add(qc_tenant)
        session.add(vigan_tenant)
        session.commit()
        session.refresh(qc_tenant)
        session.refresh(vigan_tenant)

        logger.info("Seeding Emergency Contacts...")

        # Contacts for QC District 1
        qc_contacts = [
            Contact(name="QC Police District (QCPD) Station 1", phone_number="0917-123-4567", category="Police", priority=10, protocol="tel", tenant_id=qc_tenant.id),
            Contact(name="QC DRRMO Hotline", phone_number="122", category="Rescue", priority=9, protocol="tel", tenant_id=qc_tenant.id),
            Contact(name="Barangay Santo Cristo Tanod", phone_number="viber_sto_cristo", category="Barangay", priority=5, protocol="viber", tenant_id=qc_tenant.id),
        ]

        # Contacts for Vigan
        vigan_contacts = [
            Contact(name="Vigan City Police Station", phone_number="0998-987-6543", category="Police", priority=10, protocol="tel", tenant_id=vigan_tenant.id),
            Contact(name="Ilocos Sur Provincial Hospital", phone_number="077-722-2111", category="Medical", priority=9, protocol="tel", tenant_id=vigan_tenant.id),
            Contact(name="Vigan Fire Department", phone_number="077-722-1044", category="Fire", priority=8, protocol="tel", tenant_id=vigan_tenant.id),
        ]

        for contact in qc_contacts + vigan_contacts:
            session.add(contact)

        logger.info("Seeding Newsletters...")

        # News for QC
        qc_news = [
            News(title="Road Clearing Operations this Weekend", content="Please be advised of the road clearing operations along West Avenue. Expect heavy traffic and use alternate routes.", tenant_id=qc_tenant.id),
            News(title="Suspension of Classes", content="Due to heavy rains, classes in all levels in QC are suspended today.", tenant_id=qc_tenant.id)
        ]

        # News for Vigan
        vigan_news = [
            News(title="Heritage Festival Preparation", content="Calle Crisologo will be closed to all vehicular traffic starting 5 PM for the festival preparations.", tenant_id=vigan_tenant.id)
        ]

        for news in qc_news + vigan_news:
            session.add(news)

        session.commit()
        logger.info("Demo data successfully injected!")

if __name__ == "__main__":
    create_db_and_tables()
    seed_data()